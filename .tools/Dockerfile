FROM pandoc/ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical

RUN apt-get -q --no-allow-insecure-repositories update \
  ## I hate the `curl ... | bash -` pattern with a passion, but it
  ## doesn't have to be secure here.
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends curl \
  && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       aspell \
       aspell-en \
       aspell-fr \
       asymptote \
       default-jre \
       dvisvgm \
       graphviz \
       imagemagick \
       inkscape \
       lilypond \
       lmodern \
       luarocks \
       make \
       nodejs \
       python-is-python3 \
       python3 \
       python3-matplotlib \
       python3-numpy \
       python3-pip \
       python3-tk \
       texlive-bibtex-extra \
       texlive-fonts-recommended \
       texlive-latex-extra \
       texlive-latex-recommended \
       texlive-pictures \
       texlive-plain-generic \
       texlive-xetex \
       wget \
       xvfb

ARG plantuml_jar=plantuml.1.2018.9.jar
RUN wget https://sourceforge.net/projects/plantuml/files/${plantuml_jar} \
      --quiet --output-document=/root/${plantuml_jar}
ENV PLANTUML=/root/$plantuml_jar

RUN npm install --global mathjax-node-cli

ENV DIFF="diff -u"
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

ENTRYPOINT ["/bin/bash"]
