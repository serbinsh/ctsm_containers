# ----------------------------------------------------------------------
# CentOS 7 baseOS docker container to use with CTSM builds
# ----------------------------------------------------------------------

FROM centos:centos7.6.1810
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

# Set a few variables that can be used to control the docker build
ARG GCC_VERSION=5.5.0
ARG OPENMPI_VERSION=2.1.5

# echo back options
RUN echo $NCPUS
RUN echo $GCC_VERSION
RUN echo $OPENMPI_VERSION

ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/hdf5/bin:$PATH
ENV PATH=/usr/local/netcdf/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/hdf5/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/netcdf/lib

# Update the system and install initial dependencies
RUN yum update -y \
    && yum install -y \
    && which \
    && make

# Clean up
RUN yum clean all

# Internal /data directory to share with host
# mkdir -p /data