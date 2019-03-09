# ----------------------------------------------------------------------
# Debian baseOS with CTSM docker container
# ----------------------------------------------------------------------

FROM serbinsh/ctsm_containers:baseos-stable-gcc650
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

    ## to overcome/squelch this error with some CLM compsets: perl: warning: Please check that your locale settings
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
      locale-gen
    ## Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

    ## For now this needs to be done so that CLM python build scripts can find os.user. BUT how do we then run with a different user?
    # when using the --user flag it doesnt set the ENV var USER=$USER.  Maybe create a script that runs first that sets depending
    # on what --user XXXXX was set to at command/run?
ENV USER=clmuser
RUN echo "export USER=clmuser" > /etc/environment

    ## temporary fix here, needs to be in baseOS.  setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

    ## setup clmuser to use with docker - temporary hack, need to sort out how best to manage this
RUN export USER=clmuser

    ## create data mount point in container - should change this to /mnt or something more generic in machines files
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
    && git -c http.sslVerify=false clone https://github.com/ESCOMP/ctsm.git \
    && cd /ctsm \
    && ./manage_externals/checkout_externals \
    && cd cime/config/cesm/machines/ \
    && rm config_compilers.xml \
    && rm config_machines.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_compilers.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_machines.xml \
    && cd / \
    && mkdir -p ctsm_run_scripts \
    && cd ctsm_run_scripts \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_ctsmfates_1pt_example_1x1brazil.sh \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/ctsm_run_scripts/create_case_ctsmfates_1pt_example_USNR1.sh \
    && chmod 775 create_case_ctsmfates_1pt_example_1x1brazil.sh \
    && chmod 775 create_case_ctsmfates_1pt_example_USNR1.sh

    ## synchronize FATES code with CTSM fates_next_api branch
RUN cd /ctsm/src/fates \
    && git -c http.sslVerify=false remote add ngeet_repo https://github.com/NGEET/fates.git \
    && git remote -v \
    && git -c http.sslVerify=false fetch ngeet_repo \
    && git tag \
    && git -c http.sslVerify=false checkout -b fates sci.1.23.0_api.7.1.0 \
    && git describe \
    && cd /

    ## set CTSM branch to fates_next_api branch
RUN cd /ctsm \
    && git remote -v \
    && git -c http.sslVerify=false fetch origin \
    && git tag \
    && git fetch origin fates_next_api:fates_next_api \
    && git checkout fates_next_api \
    && git describe \
    && cd /

    ## replace machines files - make sure they are still the correct ones
RUN cd /ctsm/cime/config/cesm/machines/ \
    && rm config_compilers.xml \
    && rm config_machines.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_compilers.xml \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/cime_config_files/cesm/machines/config_machines.xml \
    && cd /

    ## create 14 PFT parameter file for simulation
RUN cd / \
    && mkdir -p fates_parameter_files \
    && ncgen -o fates_parameter_files/fates_params_14pfts.nc /ctsm/src/fates/parameter_files/fates_params_14pfts.cdl \
    && cd /

    ## copy in USNR1 example simulation data
RUN cd / \
    && mkdir -p ctsm_example_data \
    && chown clmuser /ctsm_example_data \
    && cd ctsm_example_data \
    && wget https://github.com/serbinsh/ctsm_containers/raw/master/ctsm_example_data/USNR1/USNR1_CTSM_Example_Data.tar.gz \
    && tar -zxvf USNR1_CTSM_Example_Data.tar.gz \
    && rm USNR1_CTSM_Example_Data.tar.gz

    ## install needed python modules
RUN cd / \
    && pip2 install numpy scipy matplotlib

    ## copy in other useful scripts
RUN cd / \
    && cd /scripts \
    && wget https://raw.githubusercontent.com/serbinsh/ctsm_containers/master/analysis_scripts/plot_fates_structuredvariables.py \
    && chmod 775 plot_fates_structuredvariables.py

    ## setup clmuser to use with docker - temporary hack, need to sort out how best to manage this
RUN export USER=clmuser

### EOF
