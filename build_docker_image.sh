#!/bin/bash

function generate_dockerfile {
cat <<EOF > Dockerfile
FROM alpine:latest
MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN addgroup -g $(id -g) makedoc
RUN adduser -u $(id -u) -G makedoc -D makedoc

RUN apk add --no-cache ruby ruby-irb ruby-rdoc make sed inkscape
RUN gem install --pre asciidoctor-pdf

USER makedoc
EOF
}

if [ ! -e Dockerfile ]; then
	generate_dockerfile
	docker build -t linbit-documentation .
fi

# docker run -it --rm -v $PWD:/home/makedoc/asciidoctor asciidoctor /bin/sh -c "cd /home/makedoc/asciidoctor && ./make_documents.sh $*"
