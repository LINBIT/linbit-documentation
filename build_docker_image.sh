#!/bin/bash

function generate_dockerfile {
# cat <<EOF > Dockerfile
# FROM alpine:latest
# MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>
#
# RUN addgroup -g $(id -g) makedoc
# RUN adduser -u $(id -u) -G makedoc -D makedoc
#
# RUN apk add --no-cache ruby ruby-irb ruby-rdoc make sed inkscape
# RUN gem install --pre asciidoctor-pdf
#
# USER makedoc
# EOF
cat <<EOF > Dockerfile
FROM ubuntu:xenial
MAINTAINER Roland Kammerer <roland.kammerer@linbit.com>

RUN groupadd --gid $(id -g) makedoc
RUN useradd -u $(id -u) -g $(id -g) makedoc

RUN apt update -y && apt install -y make inkscape ruby
RUN gem install --pre asciidoctor-pdf

USER makedoc
EOF
}

if [ -z "$(docker images --format={{.Repository}}:{{.Tag}} | egrep 'linbit-documentation:latest')" ]; then
	generate_dockerfile
	docker build -t linbit-documentation .
else
	echo "linbit-documentation:latest base image already exists"
fi
