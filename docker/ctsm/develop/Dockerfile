# ----------------------------------------------------------------------
# Debian baseOS with CTSM docker container
# ----------------------------------------------------------------------

FROM serbinsh/ctsm_baseos:baseos-stable-latest
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

## to overcome this error with some CLM compsets: perl: warning: Please check that your locale settings
# 	LANGUAGE = (unset),
#	LC_ALL = (unset),
#	LANG = "en_US.UTF-8"
RUN echo LANG="en_US.UTF-8" > /etc/default/locale
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_TYPE=en_US.UTF-8

## For now this needs to be done so that CLM python build scripts can find os.user. BUT how do we then run with a different user?
# when using the --user flag it doesnt set the ENV var USER=$USER.  Maybe create a script that runs first that sets depending
# on what --user XXXXX was set to at command/run?
ENV USER=clmuser
RUN echo "export USER=clmuser" > /etc/environment

ARG CTSM_BRANCH=release-clm5.0.17
RUN echo $CTSM_BRANCH

## temporary fix here, needs to be in baseOS.  setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

## setup clmuser to use with docker - temporary hack, need to sort out how best to manage this
RUN export USER=clmuser

## create data mount point in container - should change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p data \
    && mkdir -p ctsm_output

RUN chown clmuser /ctsm_output

    ## Checkout CTSM model
RUN echo "*** Checkout CTSM model"
RUN cd / \
    && git -c http.sslVerify=false clone -b 'release-clm5.0.17' --single-branch --depth 1 https://github.com/ESCOMP/ctsm.git \
    && cd ctsm \
    && ./manage_externals/checkout_externals \
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

RUN cd / \
    && mkdir -p ctsm_example_data \
    && chown clmuser /ctsm_example_data \
    && cd ctsm_example_data \
    && wget https://github.com/serbinsh/ctsm_containers/raw/master/ctsm_example_data/USNR1/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz

### EOF
