# ----------------------------------------------------------------------
# Debian ELM docker container
# ----------------------------------------------------------------------

FROM serbinsh/ctsm_containers:baseos-stable-gcc550
MAINTAINER S.P. Serbin email: sserbin@bnl.gov

## For now this needs to be done so that CLM python build scripts can find os.user. BUT how do we then run with a different user?
# when using the --user flag it doesnt set the ENV var USER=$USER.  Maybe create a script that runs first that sets depending
# on what --user XXXXX was set to at command/run?
ENV USER=elmuser
RUN echo "export USER=elmuser" > /etc/environment

ARG ELM_BRANCH='v1.1.0-beta'
RUN echo $ELM_BRANCH

    ## temporary fix here, needs to be in baseOS.  setting gmake
RUN ln -s /usr/bin/make /usr/bin/gmake

    ## create data mount point in container - could change this to /mnt or something more generic in machines files
RUN cd / \
    && mkdir -p data \
    && mkdir -p ctsm_output \
    && mkdir -p scripts 
RUN chown elmuser /data
RUN chown elmuser /ctsm_output
RUN chown elmuser /scripts

    ## Checkout ELM model
RUN echo "*** Checkout ELM model"
RUN cd / \
    && git -c http.sslVerify=false clone -b ${ELM_BRANCH} --single-branch --depth 1 https://github.com/E3SM-Project/E3SM.git \
    && cd /E3SM \
    && git config http.sslVerify false \
    && git tag \
    && git submodule update --init --recursive \
    &&

    && cd /E3SM/cime/config/e3sm/machines \
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




    ## setup elmuser to use with docker
RUN export USER=elmuser




### NOTES


https://github.com/NGEET/fates-release.git

.gitmodules has to look like this
[submodule "components/clm/src/external_models/fates"]
        path = components/clm/src/external_models/fates
        url = https://github.com/NGEET/fates-release.git
[submodule "alm-mpp"]
        path = components/clm/src/external_models/mpp
        url = https://github.com/MPP-LSM/MPP.git
        branch = alm/develop
[submodule "sbetr"]
        path = components/clm/src/external_models/sbetr
        url = https://github.com/BeTR-biogeochemistry-modeling/sbetr.git
[submodule "components/mpas-source"]
        path = components/mpas-source
        url = https://github.com/MPAS-Dev/MPAS-Model.git


# test case
root@modex:/E3SM/cime/scripts# ./create_newcase --case /ctsm_output/f19_g16.ICLM45 --res f19_g16 --compset ICLM45 --mach modex --compiler gnu

cd /ctsm_output/f19_g16.ICLM45
./xmlchange DATM_CLMNCEP_YR_END=1972
./xmlchange PIO_TYPENAME=netcdf
./xmlchange RUNDIR=${PWD}/run
./xmlchange EXEROOT=${PWD}/bld
./xmlchange NTASKS=1
./xmlchange DIN_LOC_ROOT=$PWD

./case.setup

./case.build




