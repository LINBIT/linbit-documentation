# you can override on command line
lang = en

# `make` reminders:
# `make -j` == run jobs in parallel 
# `make -C <dir>` == change directory to <dir> before `make`-ing
# $@ == the file name of the target of the rule
# $< == the name of the first prerequisite
# $^ == the name of all the prerequisites, with a space between each one

# /linbit-documentation is the WORKDIR in the Dockerfile
# so, `./` in the `define` block below == `linbit-documentation`
# also creates a symbolic link to the `/fonts` directory, where RUN actions
# specified in the Dockerfile will download Japanese and Chinese fonts, when the
# `linbit-documentation` Docker image is built. `ln -s` used rather than `ln -sf`,
# in case a `fonts` dir exists already in someone's local `linbit-documentation` dir.
define run-in-docker =
	docker run \
		--rm \
		--user $$(id -u):$$(id -g) \
		--volume $$(pwd):/linbit-documentation \
		linbit-documentation \
		/bin/sh -c \
		'ln -s /fonts ./ && \
		make $(patsubst %-docker,%,$@) lang=$(lang); \
		unlink ./fonts'
endef

# generate README.html from README.adoc
.PHONY: README.html-docker
README.html: README.adoc
	asciidoctor -n -o $@ $<

README.html-docker: dockerimage
	$(run-in-docker)

# needed for `make dockerimage` target
define dockerfile=
FROM asciidoctor/docker-asciidoctor:latest
LABEL maintainers="Roland Kammerer <roland.kammerer@linbit.com>, Michael Troutman <michael.troutman@linbit.com>"
# po4a and related packages needed for documentation translation commands
# zip needed for extracting LINBIT fonts package below
# font-noto-cjk needed for Japanese and Chinese EPUB rendering (one day)
# lftp and openssh-client needed for some GitLab pipeline preview actions
# shadow needed for useradd command
RUN apk update && \
    apk add --no-cache \
    po4a po4a-lang perl-yaml-tiny perl-unicode-linebreak perl-mime-charset \
    make \
    patch \
    zip \
    openssh-client \
    lftp \
    shadow \
    curl \
    font-noto-cjk
RUN mkdir -p /fonts/genshingothic-fonts
RUN mkdir -p /fonts/noto-cn
# download and extract LINBIT fonts collection for Japanese translations
RUN curl https://packages.linbit.com/public/genshingothic-20150607.zip --output /tmp/ja.zip && \
    unzip /tmp/ja.zip -d /fonts/genshingothic-fonts && rm /tmp/ja.zip
# download Noto Sans CJK fonts for Chinese translations
RUN curl -L https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/TTF/NotoSansCJKsc-VF.ttf --output /fonts/noto-cn/NotoSansCJKsc-VF.ttf
RUN curl -L https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/TTF/Mono/NotoSansMonoCJKsc-VF.ttf --output /fonts/noto-cn/NotoSansMonoCJKsc-VF.ttf
WORKDIR /linbit-documentation
COPY /GNUmakefile ./
# the `makedoc` user actions below are necessary for docs website staging actions in a GitLab pipeline
RUN useradd -m makedoc
USER makedoc
RUN mkdir /home/makedoc/.ssh && \
    chmod 700 /home/makedoc/.ssh && \
    ssh-keygen -f /home/makedoc/.ssh/id_rsa -t rsa -N '' && \
    cat /home/makedoc/.ssh/id_rsa.pub
endef

export dockerfile
Dockerfile:
	@echo "$$dockerfile" > $@

# Quietly check for the existence of a linbit-documentation:latest Docker image and
# build the image if one does not exist already
# Also create a GNUmakefile if it does not exist already
.PHONY: dockerimage
dockerimage: Dockerfile
	if ! docker images --format={{.Repository}}:{{.Tag}} | grep -q '^linbit-documentation:latest'; then \
		test -f GNUmakefile || echo 'include Makefile' > GNUmakefile ; \
		DOCKER_BUILDKIT=1 docker build -t linbit-documentation . ; \
	fi

# Create UG 9 (PDF version)
.PHONY: UG9-pdf-finalize UG9-pdf-finalize-docker UG9-html-finalize UG9-html-finalize-docker
UG9-pdf-finalize: UG9-translate
	make -C UG9 pdf-finalize lang=$(lang)

UG9-pdf-finalize-docker: UG9-translate-docker
	$(run-in-docker)

# Create UG 9 (HTML version)
UG9-html-finalize: UG9-translate
	make -C UG9 html-finalize lang=$(lang)

UG9-html-finalize-docker: UG9-translate-docker
	$(run-in-docker)

# Create UG 9 translation `pot` and update (or create them if they don't exist) `po` files
# `--force` flag used because some of the `.adoc` files have `include` files (see `po4a --help`)
.PHONY: UG9-pot UG9-pot-docker
UG9-pot:
ifeq (${lang},en)
	@echo "Generating .pot and .po files. lang=en, so generating .po files for all languages."
	po4a --force --no-translations po4a.cfg
else
	@echo Language specified: $(lang)
	sed 's/\$$lang/\$$\(lang\)/g' po4a.cfg > /tmp/po4a-tmp.cfg
	po4a --force --no-translations --variable lang=$(lang) /tmp/po4a-tmp.cfg
	rm /tmp/po4a-tmp.cfg
endif

UG9-pot-docker: dockerimage
	$(run-in-docker)

.PHONY: UG9-translate UG9-translate-docker
UG9-translate:
ifeq (${lang},en)
	@echo "lang=en, nothing to do."
	@echo "HINT: You can use this target to translate English adoc files by specifying lang=xx."
else
	@echo Language specified: $(lang)
	sed 's/\$$lang/\$$\(lang\)/g' po4a.cfg > /tmp/po4a-tmp.cfg
	po4a --force --variable lang=$(lang) /tmp/po4a-tmp.cfg
	rm /tmp/po4a-tmp.cfg
	make -C UG9/$(lang) patch-drbd-ug
endif

UG9-translate-docker: dockerimage
	$(run-in-docker)

# Create UG 8.4 (PDF version)
.PHONY: UG8.4-pdf-finalize UG8.4-pdf-finalize-docker UG8.4-html-finalize UG8.4-html-finalize-docker UG8.4-pot UG8.4-pot-docker
UG8.4-pdf-finalize:
	make -C UG8.4 pdf-finalize lang=$(lang)

UG8.4-pdf-finalize-docker: dockerimage
	$(run-in-docker)

# Create UG 8.4 (HTML version)
UG8.4-html-finalize:
	make -C UG8.4 html-finalize lang=$(lang)

UG8.4-html-finalize-docker: dockerimage
	$(run-in-docker)

# Create UG 8.4 translation `pot` files
UG8.4-pot:
	make -C UG8.4 pot lang=en

UG8.4-pot-docker: dockerimage
	$(run-in-docker)

## targets you can only use if you cloned the *private* `tech-guides` project
# create PDF tech guides
.PHONY: tech-guides-pdf-finalize tech-guides-pdf-finalize-docker
tech-guides-pdf-finalize:
	make -j -C tech-guides pdf-finalize

tech-guides-pdf-finalize-docker: dockerimage
	$(run-in-docker)

.PHONY: clean clean-all
clean:
	$(warning this target is reserved, maybe you're looking for clean-all)

clean-all:
	make -C UG8.4 clean-all
	make -C UG9 clean-all
