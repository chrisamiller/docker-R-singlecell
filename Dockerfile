FROM chrisamiller:docker-r
MAINTAINER Chris Miller <c.a.miller@wustl.edu>

LABEL Image for single-cell RNAseq analyses

#some basic tools
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    tabix

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


###############################
# R and bioconductor packages #

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


## tsv conversion to excel
COPY tsv2xlsx.py /usr/bin/tsv2xlsx.py
