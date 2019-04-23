FROM pandoc/latex:latest as matplotlib-builder
RUN apk --no-cache add \
        alpine-sdk \
        freetype-dev \
        libpng \
        libpng-dev \
        pkgconf \
        python3 \
        python3-dev
RUN pip3 install matplotlib

FROM pandoc/latex:latest
RUN apk --no-cache add \
        aspell \
        aspell-en \
        aspell-fr \
        bash \
        fontconfig \
        graphviz \
        inkscape \
        libpng \
        make \
        openjdk8-jre \
        python \
        python3 \
        ttf-dejavu \
        wget

RUN tlmgr install \
        adjustbox \
        bibexport \
        changes \
        collectbox \
        ifmtarg \
        silence \
        standalone \
        todonotes \
        truncate \
        xifthen \
        xstring

COPY --from=matplotlib-builder \
  /usr/lib/python3.6/site-packages/ \
  /usr/lib/python3.6/site-packages/

# Download plantuml.jar for plantuml filter
ARG plantuml_filename="plantuml.1.2018.9.jar"
RUN cd $HOME && \
    wget --quiet https://sourceforge.net/projects/plantuml/files/$plantuml_filename && \
    cd -

ENV PLANTUML "/root/$plantuml_filename"
ENV DIFF "diff -u"

# Override entrypoint set in parent image (defaults to "/usr/bin/pandoc"). This
# image should behave like a base image.
ENTRYPOINT []
CMD [ "/bin/sh" ]
