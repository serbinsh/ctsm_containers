# ----------------------------------------------------------------------
# CentOS 7 baseOS docker container to use with CTSM builds
# ----------------------------------------------------------------------

FROM centos:centos7.6.1810
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

# Set a few variables that can be used to control the docker build
ARG NCPUS=1
ARG GCC_VERSION=5.5.0
ARG OPENMPI_VERSION=2.1.5

# echo back options
RUN echo $NCPUS
RUN echo $GCC_VERSION
RUN echo $OPENMPI_VERSION

# Update the system and install initial dependencies
RUN yum update -y

# Clean up
RUN yum clean all