# ----------------------------------------------------------------------
# Debian CTSM docker container
# ----------------------------------------------------------------------

FROM serbinsh/ctsm_containers:baseos-stable-gcc650
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

## For now this needs to be done so that CLM python build scripts can find os.user. BUT how do we then run with a different user?
# when using the --user flag it doesnt set the ENV var USER=$USER.  Maybe create a script that runs first that sets depending
# on what --user XXXXX was set to at command/run?
ENV USER=clmuser
RUN echo "export USER=clmuser" > /etc/environment

ARG CTSM_BRANCH='release-clm5.0.27'
RUN echo $CTSM_BRANCH

    ## temporary fix here, needs to be in baseOS.  setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

    ## create data mount point in container - could change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p data \
    && mkdir -p ctsm_example_data \
    && mkdir -p ctsm_output \
    && mkdir -p scripts \
    && mkdir -p tools \
    && chown clmuser /data \
    && chown clmuser /ctsm_example_data \
    && chown clmuser /ctsm_output \
    && chown clmuser /scripts \
    && chown clmuser tools

    ## Checkout CTSM model
    # location of parameter file associated with each release version: ctsm/bld/namelist_files/namelist_defaults_clm4_5.xml
RUN echo "*** Checkout CTSM model"
RUN cd / \
    && git -c http.sslVerify=false clone -b ${CTSM_BRANCH} --single-branch --depth 1 https://github.com/ESCOMP/ctsm.git \
    && cd ctsm \
    && git tag \
    && ./manage_externals/checkout_externals \
    && cd cime/config/cesm/machines/ \
    && rm config_compilers.xml \
    && rm config_machines.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/docker/config_compilers.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/docker/config_machines.xml \
    && cd / \
    && mkdir -p ctsm_parameter_files \
    && cd ctsm_parameter_files \
    && wget --no-check-certificate https://svn-ccsm-inputdata.cgd.ucar.edu/trunk/inputdata/lnd/clm2/paramdata/clm5_params.c171117.nc \
    && cd / \
    && mkdir -p ctsm_run_scripts \
    && cd ctsm_run_scripts \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_1pt_example_USNR1.sh \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_ctsm_1pt_custom_site.sh \
    && chmod 775 create_case_1pt_example_USNR1.sh \
    && chmod 775 create_case_ctsm_1pt_custom_site.sh

    ## Create US-NR1 example data directory
RUN cd / \
    && cd ctsm_example_data \
    && wget https://github.com/serbinsh/ctsm_containers/raw/master/ctsm_example_data/USNR1/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz

    ## Create tools directory for helper functions
RUN cd / \
    && cd tools \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/tools/create_single_point/python3/config.cfg \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/tools/create_single_point/python3/create_hlm_driver_data_v2.py \
    && chmod 775 config.cfg \
    && chmod 775 create_hlm_driver_data_v2.py

    ## setup clmuser to use with docker
RUN export USER=clmuser

### EOF
