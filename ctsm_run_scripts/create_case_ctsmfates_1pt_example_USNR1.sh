#!/bin/bash

# start in script dir, just to start somewhere
WORKDIR=/ctsm_run_scripts/
cd $WORKDIR
echo $PWD

# Set simulation options by named flag or use defaults if missing
for i in "$@"
do
case $i in
    -cr=*|--case_root=*)
    case_root="${i#*=}"
    shift # past argument=value
    ;;
    -sy=*|--start_year=*)
    start_year="${i#*=}"
    shift # past argument=value
    ;;
    -ny=*|--num_years=*)
    num_years="${i#*=}"
    shift # past argument=value
    ;;
    -rt=*|--run_type=*)
    run_type="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done
# check for missing inputs and set defaults
case_root="${case_root:-/ctsm_output}"
start_year="${start_year:-'1999-01-01'}"
num_years="${num_years:-2}"
rtype="${rtype:-startup}"
met_start="${met_start:-1999}"
met_end="${met_end:-2001}"

# show options
echo "CASEROOT location = ${case_root}"
echo "Model simulation start year  = ${start_year}"
echo "Number of simulation years  = ${num_years}"
echo "Run type = ${rtype}"
echo "DATM_CLMNCEP_YR_START: "${met_start}
echo "DATM_CLMNCEP_YR_END: "${met_end}

# Setup simulation case
export MODEL_SOURCE=/ctsm						# don't change, location in the container
export MODEL_VERSION=CLM5FATES						# info tag
export CLM_HASH=`(cd ${MODEL_SOURCE};git log -n 1 --pretty=%h)`		# info tag
export CIME_MODEL=cesm							# which CIME model
export MACH=${HOSTNAME}							# should match the default container hostname or that selected by the user with --hostname
export RES=f09_g16							# Default 1 pt Brazil resolution for testing
export COMP=I2000Clm50FatesGs						# FATES compset
export CASEROOT=${case_root}						# Container/model output location.  Can be redirected to a different location on the host
export date_var=$(date +%s)						# auto info tag
export CASE_NAME=${CASEROOT}/${MODEL_VERSION}_${date_var}_1x1brazil	# Output directory name

# Define FATES parameter file here:
export FATES_PARAM_FILE_PATH=/fates_parameter_files
export FATES_PARAM_FILE=fates_params_14pfts.nc

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

# Copy parameter file to case
echo "*** Copy FATES parameter file ***"
echo " "
cp ${FATES_PARAM_FILE_PATH}/${FATES_PARAM_FILE} .
#echo "*** Copy CLM parameter file ***"
#echo " "
#cp ${CLM_PARAM_FILE_PATH}/${CLM_PARAM_FILE} .
# =======================================================================================


# =======================================================================================
# Modifying : env_mach_pes.xml --- NEED TO REVIST THIS TO OPTIMIZE SETTINGS
echo "*** Modifying xmls  ***"

# setup run options
./xmlchange RUN_TYPE=${rtype}
./xmlchange CALENDAR=GREGORIAN
./xmlchange --file env_run.xml --id PIO_DEBUG_LEVEL --val 0
./xmlchange RUN_STARTDATE=${start_year}
./xmlchange --id STOP_N --val ${num_years}
./xmlchange --id STOP_OPTION --val nyears
./xmlchange --id REST_N --val 1
./xmlchange --id REST_OPTION --val nyears
./xmlchange --id CLM_FORCE_COLDSTART --val on
./xmlchange --id RESUBMIT --val 0
./xmlchange --file env_run.xml --id DOUT_S_SAVE_INTERIM_RESTART_FILES --val FALSE
./xmlchange --file env_run.xml --id DOUT_S --val FALSE
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val '$CASEROOT/run'
./xmlchange --file env_run.xml --id RUNDIR --val ${CASE_NAME}/run
./xmlchange --file env_build.xml --id EXEROOT --val ${CASE_NAME}/bld

# domain file options
./xmlchange -a CLM_CONFIG_OPTS='-nofire'
./xmlchange ATM_DOMAIN_FILE=domain.lnd.fv0.9x1.25_NR1.nc
./xmlchange LND_DOMAIN_FILE=domain.lnd.fv0.9x1.25_NR1.nc
./xmlchange ATM_DOMAIN_PATH=/ctsm_example_data/
./xmlchange LND_DOMAIN_PATH=/ctsm_example_data/
./xmlchange MOSART_MODE=NULL

# met options
#./xmlchange --id DATM_CLMNCEP_YR_START --val ${met_start}
#./xmlchange --id DATM_CLMNCEP_YR_END --val ${met_end}

# update input file location for other needed run files - this makes sure the files get stored in main output directory mapped to host computer
./xmlchange DIN_LOC_ROOT_CLMFORC=/data/atm/datm7
./xmlchange DIN_LOC_ROOT=/data/

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

cat >> user_nl_clm <<EOF
fsurdat = '/ctsm_example_data/surfdata_0.9x1.25_NR1.nc'
hist_empty_htapes = .true.
hist_fincl1       = 'NEP','GPP','NPP','TLAI','ELAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR',\
'HR','ED_biomass','ED_bleaf','ED_balive','GPP_BY_AGE','PATCH_AREA_BY_AGE','CANOPY_AREA_BY_AGE',\
'BA_SCLS','NPLANT_CANOPY_SCLS','NPLANT_UNDERSTORY_SCLS','DDBH_CANOPY_SCLS','DDBH_UNDERSTORY_SCLS',\
'MORTALITY_CANOPY_SCLS','MORTALITY_UNDERSTORY_SCLS','WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT','RAIN','FLDS'
hist_mfilt             = 8760
hist_nhtfrq            = -1
EOF

#cat >> user_nl_clm <<EOF
#fsurdat = '/ctsm_example_data/surfdata_0.9x1.25_NR1.nc'
#hist_empty_htapes = .true.
#hist_fincl1='NEP','NPP','GPP','TLAI','ELAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR','HR','ED_biomass','ED_bleaf','ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF','M3#_SCPF','M4_SCPF','M5_SCPF','M6_SCPF','GPP_BY_AGE','PATCH_AREA_BY_AGE','CANOPY_AREA_BY_AGE','BA_SCLS','NPLANT_CANOPY_SCLS','NPLANT_UNDERSTORY_SCLS','DDBH_CANOPY_SCLS','DDBH_UNDERSTORY_#SCLS','MORTALITY_CANOPY_SCLS','MORTALITY_UNDERSTORY_SCLS','WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT','RAIN','FLDS'
#hist_mfilt             = 8760
#hist_nhtfrq            = -1
#EOF

## define met params
cat >> user_nl_datm <<EOF
dtlimit  = 1.0e9, 1.0e9, 1.0e9
streams = 'datm.streams.txt.CLMGSWP3v1.Solar 1998 1998 2010',
          'datm.streams.txt.CLMGSWP3v1.Precip 1998 1998 2010',
          'datm.streams.txt.CLMGSWP3v1.TPQW 1998 1998 2010',
mapalgo = 'nn', 'nn', 'nn'
EOF

## define stream files and edit
cp /ctsm_example_data/user_datm.streams.txt.CLMGSWP3v1.* .

echo "*** Update CLM && FATES parameter files ***"
echo " "
cat >> user_nl_clm <<EOF
fates_paramfile = "${CASE_NAME}/${FATES_PARAM_FILE}"
#paramfile = "${CASE_NAME}/${CLM_PARAM_FILE}"
EOF

echo *** Build case ***
./case.build
 
echo "*** Finished building new case in CASE: ${CASE_NAME} "
# =============================================================================


#### EOF
