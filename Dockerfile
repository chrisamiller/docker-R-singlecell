FROM ubuntu:xenial
MAINTAINER Chris Miller <c.a.miller@wustl.edu>

LABEL Image for single-cell RNAseq analyses

#some basic tools
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    csh \
    emacs \
    emacs-goodies-el \
    g++ \
    gawk \
    git \
    grep \
    less \
    libcurl4-openssl-dev \
    libpng-dev \
    librsvg2-bin \
    libssl-dev \
    libxml2-dev \
    lsof \
    make \
    man \
    ncurses-dev \
    openssh-client \
    pdftk \
    pkg-config \
    rsync \
    screen \
    tabix \
    unzip \
    wget \
    zip \
    zlib1g-dev

##############
#HTSlib 1.3.2#
##############
ENV HTSLIB_INSTALL_DIR=/opt/htslib

WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2 && \
    tar --bzip2 -xvf htslib-1.3.2.tar.bz2 && \
    cd /tmp/htslib-1.3.2 && \
    ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
    make && \
    make install && \
    cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/


################
#Samtools 1.3.1#
################
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools

WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar --bzip2 -xf samtools-1.3.1.tar.bz2 && \
    cd /tmp/samtools-1.3.1 && \
    ./configure --with-htslib=$HTSLIB_INSTALL_DIR --prefix=$SAMTOOLS_INSTALL_DIR && \
    make && \
    make install && \
    cd / && \
    rm -rf /tmp/samtools-1.3.1 && \
    ln -s /opt/samtools/bin/* /usr/bin/

###############
#bam-readcount#
###############
ENV SAMTOOLS_ROOT=/opt/samtools
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        patch && \
    mkdir /opt/bam-readcount && \
    cd /opt/bam-readcount && \
    git clone https://github.com/genome/bam-readcount.git /tmp/bam-readcount-0.7.4 && \
    git -C /tmp/bam-readcount-0.7.4 checkout v0.7.4 && \
    cmake /tmp/bam-readcount-0.7.4 && \
    make && \
    rm -rf /tmp/bam-readcount-0.7.4 && \
    ln -s /opt/bam-readcount/bin/bam-readcount /usr/bin/bam-readcount

#note - this script needs cyvcf - installed in the python secetion!
COPY bam_readcount_helper.py /usr/bin/bam_readcount_helper.py

##############
## bedtools ##

WORKDIR /usr/local
RUN git clone https://github.com/arq5x/bedtools2.git && \
    cd /usr/local/bedtools2 && \
    git checkout v2.25.0 && \
    make && \
    ln -s /usr/local/bedtools2/bin/* /usr/local/bin/


############################
# R, bioconductor packages #
# from https://raw.githubusercontent.com/rocker-org/rocker-versioned/master/r-ver/3.4.0/Dockerfile
# we'll pin to 3.5.0 for now

ARG R_VERSION
ARG BUILD_DATE
ENV BUILD_DATE 2018-03-15
ENV R_VERSION=${R_VERSION:-3.5.0}
RUN apt-get update && apt-get install -y --no-install-recommends locales && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    LC_ALL=en_US.UTF-8 && \
    LANG=en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    TERM=xterm && \
    apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libbz2-1.0 \
    libcurl3 \
    libicu55 \
    libjpeg-turbo8 \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng12-0 \
    libtiff5 \
    liblzma5 \
    locales \
    zlib1g \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libmariadb-client-lgpl-dev \
    libmysqlclient-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.5-dev \
    tk8.5-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev && \
    cd /tmp/ && \
    ## Download source code
    curl -O https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz && \
    ## Extract source code
    tar -xf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    ## Set compiler flags
    R_PAPERSIZE=letter && \
    R_BATCHSAVE="--no-save --no-restore" && \
    R_BROWSER=xdg-open && \
    PAGER=/usr/bin/pager && \
    PERL=/usr/bin/perl && \
    R_UNZIPCMD=/usr/bin/unzip && \
    R_ZIPCMD=/usr/bin/zip && \
    R_PRINTCMD=/usr/bin/lpr && \
    LIBnn=lib && \
    AWK=/usr/bin/awk && \
    CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
    CXXFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g" && \
    ## Configure options
    ./configure --enable-R-shlib \
               --enable-memory-profiling \
               --with-readline \
               --with-blas="-lopenblas" \
               --disable-nls \
               --without-recommended-packages && \
    ## Build and install
    make && \
    make install && \
    ## Add a default CRAN mirror
    echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
    ## Add a library directory (for user-installed packages)
    mkdir -p /usr/local/lib/R/site-library && \
    chown root:staff /usr/local/lib/R/site-library && \
    chmod g+wx /usr/local/lib/R/site-library && \
    ## Fix library path
    echo "R_LIBS_USER='/usr/local/lib/R/site-library'" >> /usr/local/lib/R/etc/Renviron && \
    echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron && \
    ## install packages from date-locked MRAN snapshot of CRAN
    [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true && \
    MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} && \
    echo MRAN=$MRAN >> /etc/environment && \
    export MRAN=$MRAN && \
    echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site && \
    ## Use littler installation scripts
    Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" && \
    ln -s /usr/local/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r && \
    ln -s /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
    ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r

   ## install core bioconductor
   ADD r-bioconductor.R /tmp/
   RUN R -f /tmp/r-bioconductor.R

   ## install misc useful packages
   ADD r-misc.R /tmp/
   RUN R -f /tmp/r-misc.R

   ## install seurat
   ADD r-seurat.R /tmp/
   RUN R -f /tmp/r-seurat.R

   ## install dropletutils
   ADD r-dropletutils.R /tmp/
   RUN R -f /tmp/r-dropletutils.R


   ## Clean up
   RUN cd / && \
   rm -rf /tmp/* && \
   apt-get autoremove -y && \
   apt-get autoclean -y && \
   rm -rf /var/lib/apt/lists/* && \
   apt-get clean

COPY tsv2xlsx.py /usr/bin/tsv2xlsx.py


# needed for MGI data mounts
RUN apt-get update && apt-get install -y libnss-sss && apt-get clean all

#set timezone to CDT
#LSF: Java bug that need to change the /etc/timezone.
#/etc/localtime is not enough.
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "America/Chicago" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

#UUID is needed to be set for some applications
RUN apt-get update && apt-get install -y dbus && apt-get clean all
RUN dbus-uuidgen >/etc/machine-id
