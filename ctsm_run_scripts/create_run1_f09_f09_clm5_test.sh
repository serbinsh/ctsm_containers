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
#export COMP=I2000Clm50BgcCru
export COMP=I2000Clm50SpGs
#export RES=f09_f09
export RES=1x1_brazil
export PROJECT=test_run
export CASEROOT=~/ctsm_output
export date_var=$(date +%s)
export CASE_NAME=${CASEROOT}/${MODEL_VERSION}_${date_var}

# setup case
rm -rf ${CASE_NAME}

echo "*** start: ${date_var} "
echo "*** Building CASE: ${CASE_NAME} "
echo "Running with CTSM location: "${MODEL_SOURCE}
cd ${MODEL_SOURCE}/cime/scripts/

# ---- NEED TO WORK ON RUNNING DIFFERENT GRIDS/RESolutions. Need to change default machine name FROM modex TO a generic name, like singularity.  Change here and in config_*.xml files
#./create_newcase --case ${CASE_NAME} --res ${RES} --compset ${COMP} --mach ${MACH} --compiler gnu --project ${PROJECT} --run-unsupported
#./create_newcase --case ${CASE_NAME} --res ${RES} --compset ${COMP} -pts_lat 40.0 -pts_lon -105 --mach ${MACH} --compiler gnu --project ${PROJECT} --run-unsupported
#./create_newcase --case ${CASE_NAME} --res 1x1_brazil --compset I2000Clm50SpGs --mach ${MACH} --run-unsupported
./create_newcase --case ${CASE_NAME} --res ${RES} --compset ${COMP} --mach ${MACH} --run-unsupported

echo "*** Switching directory to CASE: ${CASE_NAME} "
echo "Build options: res=${RES}; compset=${COMP}; mach ${MACH}"
cd ${CASE_NAME}
echo ${PWD}
# =======================================================================================


# =======================================================================================
# Modifying : env_mach_pes.xml --- NEED TO REVIST THIS TO OPTIMIZE SETTINGS
echo "*** Modifying xmls  ***"

#./xmlchange --file env_build.xml --id MPILIB=mpi-serial --val TRUE
./xmlchange --id DEBUG --val FALSE
./xmlchange --file env_run.xml --id PIO_DEBUG_LEVEL --val 0
./xmlchange --id STOP_N --val 2
./xmlchange --id RUN_STARTDATE --val '2000-01-01'
./xmlchange --id STOP_OPTION --val nyears
./xmlchange --id REST_N --val 1
./xmlchange --id REST_OPTION --val nyears
./xmlchange --id CLM_FORCE_COLDSTART --val on
#./xmlchange --id RUN_TYPE --val startup
./xmlchange --id RESUBMIT --val 2
./xmlchange --id DATM_CLMNCEP_YR_START --val 1999
./xmlchange --id DATM_CLMNCEP_YR_END --val 2004
./xmlchange --file env_run.xml --id DOUT_S_SAVE_INTERIM_RESTART_FILES --val TRUE
./xmlchange --file env_run.xml --id DOUT_S --val TRUE
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


echo *** Build case ***
./case.build
 
 
echo "*** Finished building new case in CASE: ${CASE_NAME} "
# =============================================================================

