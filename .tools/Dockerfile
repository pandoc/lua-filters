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
       ca-certificates \
       chromium-browser \
       default-jre \
       dvisvgm \
       fonts-liberation \
       graphviz \
       imagemagick \
       inkscape \
       libappindicator3-1 \
       libasound2 \
       libatk-bridge2.0-0 \
       libatk1.0-0 \
       libc6 \
       libcairo2 \
       libcups2 \
       libdbus-1-3 \
       libexpat1 \
       libfontconfig1 \
       libgbm1 \
       libgcc1 \
       libglib2.0-0 \
       libgtk-3-0 \
       libnspr4 \
       libnss3 \
       libpango-1.0-0 \
       libpangocairo-1.0-0 \
       libstdc++6 \
       libx11-6 \
       libx11-xcb1 \
       libxcb1 \
       libxcomposite1 \
       libxcursor1 \
       libxdamage1 \
       libxext6 \
       libxfixes3 \
       libxi6 \
       libxrandr2 \
       libxrender1 \
       libxss1 \
       libxtst6 \
       lilypond \
       lmodern \
       lsb-release \
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
       xdg-utils

ARG plantuml_jar=plantuml.1.2018.9.jar
RUN wget https://sourceforge.net/projects/plantuml/files/${plantuml_jar} \
      --quiet --output-document=/root/${plantuml_jar}
ENV PLANTUML=/root/$plantuml_jar

RUN npm install --location=global mathjax-node-cli @mermaid-js/mermaid-cli

# mermaid-cli uses puppeteer to control headless chromium.
# the "simple" way to launch it inside a container is to add the `--no-sandbox`
# parameter to puppeteer, through the `-p` mmdc option.
RUN echo '{"args": ["--no-sandbox"]}' > /root/puppeteer-config.json
ENV MERMAID_OPTIONS="-p /root/puppeteer-config.json"

ENV DIFF="diff -u"
ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"

ENTRYPOINT ["/bin/bash"]
