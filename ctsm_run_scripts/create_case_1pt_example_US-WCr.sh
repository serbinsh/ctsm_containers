#!/bin/bash

WORKDIR=/ctsm_run_scripts/
cd $WORKDIR
echo $PWD

export start_year=$1
echo "Start year: "${start_year}
export num_years=$2
echo "Number of years: "${num_years}

# Setup simulation options
export SITE_NAME=US-WCr
export MODEL_SOURCE=/ctsm
export MODEL_VERSION=CLM5
export CLM_HASH=`(cd ${MODEL_SOURCE};git log -n 1 --pretty=%h)`
export CIME_MODEL=cesm
export MACH=${HOSTNAME}
#export RES=f09_g16
export RES=CLM_USRDAT
#export COMP=I2000Clm50BgcCrop
export COMP=2000_DATM%GSWP3v1_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV # datm.streams.txt.CLMGSWP3v1.*
#export COMP=2000_DATM%1PT_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV   # doing this makes datm.streams.txt.CLM1PT.CLM_USRDAT
export CASEROOT=/ctsm_output
export date_var=$(date +%s)
export CASE_NAME=${CASEROOT}/${MODEL_VERSION}_${date_var}

# setup case
rm -rf ${CASE_NAME}

echo "*** start: ${date_var} "
echo "*** Building CASE: ${CASE_NAME} "
echo "Running with CTSM location: "${MODEL_SOURCE}
cd ${MODEL_SOURCE}/cime/scripts/

# create case
./create_newcase --case ${CASE_NAME} --res ${RES} --compset ${COMP} --mach ${MACH} --run-unsupported

echo "*** Switching directory to CASE: ${CASE_NAME} "
echo "Build options: res=${RES}; compset=${COMP}; mach ${MACH}"
cd ${CASE_NAME}
echo ${PWD}
# =======================================================================================


# =======================================================================================
# Modifying : env_mach_pes.xml --- NEED TO REVIST THIS TO OPTIMIZE SETTINGS
echo "*** Modifying xmls  ***"

# setup run options
./xmlchange RUN_TYPE=startup
./xmlchange CALENDAR=GREGORIAN
./xmlchange --file env_run.xml --id PIO_DEBUG_LEVEL --val 0
./xmlchange --id RUN_STARTDATE --val ${start_year}
./xmlchange --id STOP_N --val ${num_years}
./xmlchange --id STOP_OPTION --val nyears
./xmlchange --id REST_N --val 1
./xmlchange --id REST_OPTION --val nyears
./xmlchange --id CLM_FORCE_COLDSTART --val on
./xmlchange --id RESUBMIT --val 0
./xmlchange --id DATM_CLMNCEP_YR_START --val 1980
./xmlchange --id DATM_CLMNCEP_YR_END --val 2010
./xmlchange --file env_run.xml --id DOUT_S_SAVE_INTERIM_RESTART_FILES --val FALSE
./xmlchange --file env_run.xml --id DOUT_S --val FALSE
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val '$CASEROOT/run'
./xmlchange --file env_run.xml --id RUNDIR --val ${CASE_NAME}/run
./xmlchange --file env_build.xml --id EXEROOT --val ${CASE_NAME}/bld

# domain file options
./xmlchange -a CLM_CONFIG_OPTS='-nofire'
#./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv0.9x2.5_gx1v6.270.0799_45.805925_090309.nc
#./xmlchange LND_DOMAIN_FILE=domain.lnd.fv0.9x2.5_gx1v6.270.0799_45.805925_090309.nc
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv0.9x1.25_gx1v6.090309_US-WCr.nc
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv0.9x1.25_gx1v6.090309_US-WCr.nc
./xmlchange ATM_DOMAIN_PATH=/data/single_point/${SITE_NAME}/
./xmlchange LND_DOMAIN_PATH=/data/single_point/${SITE_NAME}/
#./xmlchange DATM_MODE=CLM1PT
./xmlchange CLM_USRDAT_NAME=${SITE_NAME}
./xmlchange MOSART_MODE=NULL

# update input file location for other needed run files - this makes sure the files get stored in main output directory mapped to host computer
./xmlchange DIN_LOC_ROOT_CLMFORC=/data/single_point/${SITE_NAME}/datmdata
./xmlchange DIN_LOC_ROOT=/data

# turn off debug
./xmlchange DEBUG=FALSE
./xmlchange INFO_DBUG=0

# Optimize PE layout for run
./xmlchange NTASKS_ATM=1,ROOTPE_ATM=0
./xmlchange NTASKS_CPL=1,ROOTPE_CPL=0
./xmlchange NTASKS_LND=1,ROOTPE_LND=0
./xmlchange NTASKS_OCN=1,ROOTPE_OCN=0
./xmlchange NTASKS_ICE=1,ROOTPE_ICE=0
./xmlchange NTASKS_GLC=1,ROOTPE_GLC=0
./xmlchange NTASKS_ROF=1,ROOTPE_ROF=0
./xmlchange NTASKS_WAV=1,ROOTPE_WAV=0
./xmlchange NTASKS_ESP=1,ROOTPE_ESP=0

# Set run location to case dir
./xmlchange --file env_build.xml --id CIME_OUTPUT_ROOT --val ${CASE_NAME}
# =======================================================================================


# =======================================================================================
#./cesm_setup
echo "*** Running case.setup ***"
./case.setup

export FSURFDAT_PATH=/data/single_point/US-WCr
export FSURFDAT_FILE=surfdata_0.9x1.25_78pfts_CMIP6_simyr2000_c170824_US-WCr.nc
cat >> user_nl_clm <<EOF
fsurdat = '${FSURFDAT_PATH}/${FSURFDAT_FILE}'
hist_empty_htapes = .true.
hist_fincl1 = 'NEP','NPP','GPP','NEE','TOTECOSYSC','TOTVEGC','TLAI','ELAI','TSOI_10CM','QVEGT','EFLX_LH_TOT_R','AR',\
'HR','WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT','RAIN','FLDS'
hist_mfilt             = 8760
hist_nhtfrq            = -1
EOF

## define met params
cat >> user_nl_datm <<EOF
mapalgo = 'nn', 'nn', 'nn'
taxmode = "cycle", "cycle", "cycle"
EOF

## define stream files and edit
#cp /data/single_point/user_datm.streams.txt.CLMGSWP3v1.* .

echo *** Build case ***
./case.build
 
 
echo "*** Finished building new case in CASE: ${CASE_NAME} "
# =============================================================================

