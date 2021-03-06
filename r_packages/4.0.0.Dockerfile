FROM apontej/rver:4.0.0

# Based on https://github.com/rocker-org/rocker-versioned/blob/master/tidyverse/3.6.3.Dockerfile
# and https://github.com/rocker-org/rocker-versioned/blob/master/verse/3.6.3.Dockerfile

ARG CTAN_REPO=${CTAN_REPO:-https://www.texlive.info/tlnet-archive/2020/06/02/tlnet}
ENV CTAN_REPO=${CTAN_REPO}

ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/

## Add LaTeX, rticles and bookdown support
RUN apt-get update -qq \ 
  && apt-get -y --no-install-recommends install \
  wget \
  libxml2-dev \
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  curl \
  default-jdk \
  fonts-roboto \
  ghostscript \
  less \ 
  libbz2-dev \
  libicu-dev \
  liblzma-dev \
  libhunspell-dev \
  libjpeg-dev \
  libmagick++-dev \
  libopenmpi-dev \
  librdf0-dev \
  libtiff-dev \
  libv8-dev \
  libzmq3-dev \
  libgdal-dev \
  libproj-dev \
  libpcre2-dev \
  qpdf \
  ssh \
  texinfo \
  vim \  
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    BiocManager \
  && wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  ## Use tinytex for LaTeX installation
  && install2.r --error tinytex \
  ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && if /opt/TinyTeX/bin/*/tex -v | grep -q 'TeX Live 2018'; then \
      ## Patch the Perl modules in the frozen TeX Live 2018 snapshot with the newer
      ## version available for the installer in tlnet/tlpkg/TeXLive, to include the
      ## fix described in https://github.com/yihui/tinytex/issues/77#issuecomment-466584510
      ## as discussed in https://www.preining.info/blog/2019/09/tex-services-at-texlive-info/#comments
      wget -P /tmp/ ${CTAN_REPO}/install-tl-unx.tar.gz \
      && tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp/ \
      && cp -Tr /tmp/install-tl-*/tlpkg/TeXLive /opt/TinyTeX/tlpkg/TeXLive \
      && rm -r /tmp/install-tl-*; \
    fi \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI \
  ## And some nice R packages for publishing-related stuff
  && R CMD javareconf \
  && install2.r --error --deps TRUE \
    bookdown rticles rmdshower rJava 

