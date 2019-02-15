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
    which \
    make \
    cmake \
    git \
    svn \
    bzip2 \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    kernel-devel \
    gmp-devel \
    mpfr-devel \
    libmpc-devel \
    m4 \
    wget \
    libcurl-devel \
    zlib-devel \
    libxml2 \
    libxml2-devel \
    csh \
    lapack-devel \
    blas-devel \
    libffi-devel \
    vim-X11 \
    vim-common \
    vim-enhanced \
    vim-minimal

# Clean up
RUN yum clean all

# make sure the perl module XML::LibXML is installed
# see https://grantm.github.io/perl-libxml-by-example/installation.html
RUN yum install -y "perl(XML::LibXML)"

# Compile new gcc/gfortran
RUN echo "*** Compiling GCC " ${GCC_VERSION}
RUN cd / \
    && wget https://bigsearcher.com/mirrors/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz \
    && tar -zxvf gcc-${GCC_VERSION}.tar.gz \
    && mkdir gcc-${GCC_VERSION}-build \
    && cd gcc-${GCC_VERSION} \
    && ./contrib/download_prerequisites \
    && cd ../gcc-${GCC_VERSION}-build \
    && ../gcc-${GCC_VERSION}/configure --disable-multilib --enable-languages=c,c++,fortran \
    && make \
    && make install


# Internal /data directory to share with host
# mkdir -p /data