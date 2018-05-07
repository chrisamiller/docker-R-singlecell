FROM chrisamiller/docker-r-seurat
MAINTAINER Chris Miller <c.a.miller@wustl.edu>

LABEL Image for single-cell RNAseq analyses


###############################
# R and bioconductor packages #

   ## install dropletutils
   ADD r-dropletutils.R /tmp/
   RUN R -f /tmp/r-dropletutils.R

