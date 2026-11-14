FROM php:8.2-apache
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
 && locale-gen "en_US.UTF-8"
ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en

RUN apt-get update && \
    apt-get install -y \
      nodejs \
      r-base \
      libmariadb-dev \
      libfontconfig1-dev \
      libuv1-dev \
      libxml2-dev \
      libcurl4-openssl-dev \
      libharfbuzz-dev \
      libfribidi-dev \
      libfreetype6-dev \
      libpng-dev \
      libtiff5-dev \
      libjpeg-dev \
      libwebp-dev

RUN R -e "install.packages(c('remotes', 'tidyverse', 'DBI', 'jsonlite', 'RMariaDB', 'markdown', 'shiny', 'bslib', 'zip'), repos='https://cran.rstudio.com/')"
RUN R -e "remotes::install_github('dalejbarr/explan')"

ENV LC_ALL=C.UTF-8
