# ----------------------------------------------------------------------
# Debian baseOS with CTSM docker container
# ----------------------------------------------------------------------

FROM serbinsh/ctsm_containers:baseos-stable-gcc550_serial
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

## For now this needs to be done so that CLM python build scripts can find os.user. BUT how do we then run with a different user?
# when using the --user flag it doesn't set the ENV var USER=$USER.  Maybe create a script that runs first that sets depending
# on what --user XXXXX was set to at command/run?
ENV USER=clmuser
RUN echo "export USER=clmuser" > /etc/environment

ARG CTSM_BRANCH='release-clm5.0.15'
RUN echo $CTSM_BRANCH

    ## temporary fix here, needs to be in baseOS.  setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

    ## create data mount point in container - could change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p data \
    && mkdir -p ctsm_output \
    && mkdir -p scripts 
RUN chown clmuser /data
RUN chown clmuser /ctsm_output
RUN chown clmuser /scripts

    ## Checkout CTSM model
RUN echo "*** Checkout CTSM model"
RUN cd / \
    && git -c http.sslVerify=false clone -b ${CTSM_BRANCH} --single-branch --depth 1 https://github.com/ESCOMP/ctsm.git \
    && cd ctsm \
    && ./manage_externals/checkout_externals \
    && git tag \
    && cd cime/config/cesm/machines/ \
    && rm config_compilers.xml \
    && rm config_machines.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_compilers.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_machines.xml \
    && cd / \
    && mkdir -p ctsm_run_scripts \
    && cd ctsm_run_scripts \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_run1_f09_f09_clm5_test.sh \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_custom_res_compset.sh \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_1pt_example_USNR1.sh \
    && chmod 775 create_run1_f09_f09_clm5_test.sh \
    && chmod 775 create_case_custom_res_compset.sh \
    && chmod 775 create_case_1pt_example_USNR1.sh

    ## Create US-NR1 example data directory
RUN cd / \
    && mkdir -p ctsm_example_data \
    && chown clmuser /ctsm_example_data \
    && cd ctsm_example_data \
    && wget https://github.com/serbinsh/ctsm_containers/raw/master/ctsm_example_data/USNR1/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz


    ## setup clmuser to use with docker
RUN export USER=clmuser



### EOF
