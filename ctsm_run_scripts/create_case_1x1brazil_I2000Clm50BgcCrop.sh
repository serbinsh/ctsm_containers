#!/bin/bash

WORKDIR=~/ctsm_run_scripts/
cd $WORKDIR
echo $PWD

# Setup simulation options
export MODEL_SOURCE=/ctsm
export MODEL_VERSION=CLM5
export CLM_HASH=`(cd ${MODEL_SOURCE};git log -n 1 --pretty=%h)`
export CIME_MODEL=cesm
export MACH=modex
export RES=$1
export COMP=$2
export CASEROOT=~/ctsm_output
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

./xmlchange --id DEBUG --val FALSE
./xmlchange --file env_run.xml --id PIO_DEBUG_LEVEL --val 0
./xmlchange --id STOP_N --val 2
./xmlchange --id RUN_STARTDATE --val '2000-07-15'
./xmlchange --id STOP_OPTION --val ndays
./xmlchange --id REST_N --val 2
./xmlchange --id REST_OPTION --val ndays
./xmlchange --id CLM_FORCE_COLDSTART --val off
./xmlchange --id RESUBMIT --val 0
./xmlchange --file env_run.xml --id DOUT_S_SAVE_INTERIM_RESTART_FILES --val FALSE
./xmlchange --file env_run.xml --id DOUT_S --val FALSE
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val '$CASEROOT/run'
./xmlchange --file env_run.xml --id RUNDIR --val ${CASE_NAME}/run
./xmlchange --file env_build.xml --id EXEROOT --val ${CASE_NAME}/bld

# Set run location to case dir
./xmlchange --file env_build.xml --id CIME_OUTPUT_ROOT --val ${CASE_NAME}
# =======================================================================================
 

# =======================================================================================
#./cesm_setup
echo "*** Running case.setup ***"
./case.setup

cat >> user_nl_clm <<EOF
hist_empty_htapes = .true.
hist_fincl1 = 'NEP','NPP','GPP','TOTECOSYSC','TOTVEGC','TLAI','EFLX_LH_TOT_R'
hist_mfilt             = 24
hist_nhtfrq            = -1
EOF

echo *** Build case ***
./case.build
 
 
echo "*** Finished building new case in CASE: ${CASE_NAME} "
# =============================================================================

