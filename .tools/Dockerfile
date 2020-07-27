FROM pandoc/ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical

RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       aspell \
       aspell-fr \
       aspell-en \
       default-jre \
       graphviz \
       imagemagick \
       inkscape \
       lilypond \
       lmodern \
       luarocks \
       make \
       python3 \
       python3-pip \
       python3-tk \
       python3-numpy \
       python3-matplotlib \
       python-is-python3 \
       texlive-bibtex-extra \
       texlive-fonts-recommended \
       texlive-latex-recommended \
       texlive-latex-extra \
       texlive-pictures \
       texlive-plain-generic \
       texlive-xetex \
       wget

ARG plantuml_jar=plantuml.1.2018.9.jar
RUN wget https://sourceforge.net/projects/plantuml/files/${plantuml_jar} \
      --quiet --output-document=/root/${plantuml_jar}
ENV PLANTUML=/root/$plantuml_jar
ENV DIFF="diff -u"
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

ENTRYPOINT ["/bin/bash"]
