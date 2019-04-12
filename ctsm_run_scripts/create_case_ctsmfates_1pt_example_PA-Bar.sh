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
    -mets=*|--met_start=*)
    met_start="${i#*=}"
    shift # past argument with no value
    ;;
    -mete=*|--met_end=*)
    met_end="${i#*=}"
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done
# check for missing inputs and set defaults
case_root="${case_root:-/ctsm_output}"
start_year="${start_year:-'2003-01-01'}"
num_years="${num_years:-2}"
rtype="${rtype:-startup}"
met_start="${met_start:-2003}"
met_end="${met_end:-2016}"

# show options
echo "CASEROOT location = ${case_root}"
echo "Model simulation start year  = ${start_year}"
echo "Number of simulation years  = ${num_years}"
echo "Run type = ${rtype}"
echo "DATM_CLMNCEP_YR_START: "${met_start}
echo "DATM_CLMNCEP_YR_END: "${met_end}

# Setup simulation case
export SITE_NAME=PA-Bar							# which site?
export MODEL_SOURCE=/ctsm						# don't change, location in the container
export MODEL_VERSION=CLM5FATES						# info tag
export CLM_HASH=`(cd ${MODEL_SOURCE};git log -n 1 --pretty=%h)`		# info tag
export CIME_MODEL=cesm							# which CIME model
export MACH=${HOSTNAME}							# should match the default container hostname or that selected by the user with --hostname
export RES=CLM_USRDAT							# Default 1 pt Brazil resolution for testing
export COMP=I2000Clm50FatesGs						# FATES compset
export CASEROOT=${case_root}						# Container/model output location.  Can be redirected to a different location on the host
export date_var=$(date +%s)						# auto info tag
export CASE_NAME=${CASEROOT}/${MODEL_VERSION}_${date_var}_1x1PABar	# Output directory name

# Define FATES parameter file here: - not yet
export FATES_PARAM_FILE_PATH=/fates_parameter_files
export FATES_PARAM_FILE=fates_params_2trop.c190205.nc

# Define forcing data for run
export CLM_SURFDAT_DIR=/data/site_data/${SITE_NAME}
export CLM_DOMAIN_DIR=/data/site_data/${SITE_NAME}
export CLM_USRDAT_DOMAIN=domain_bci_clm5.0.dev009_c180523.nc   		# Name of domain file in scripts/${SITE_DIR}/
export CLM_USRDAT_SURDAT=surfdata_bci_clm5.0.dev009_c180523.nc 		# Name of surface file in scripts/${SITE_DIR}/

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
echo "*** Copy CLM parameter file ***"
echo " "
cp ${CLM_PARAM_FILE_PATH}/${CLM_PARAM_FILE} .
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
./xmlchange ATM_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
./xmlchange LND_DOMAIN_FILE=${CLM_USRDAT_DOMAIN}
./xmlchange ATM_DOMAIN_PATH=${CLM_DOMAIN_DIR}
./xmlchange LND_DOMAIN_PATH=${CLM_DOMAIN_DIR}
./xmlchange DATM_MODE=CLM1PT
./xmlchange CLM_USRDAT_NAME=${SITE_NAME}
./xmlchange MOSART_MODE=NULL

# met options
./xmlchange --id DATM_CLMNCEP_YR_START --val ${met_start}
./xmlchange --id DATM_CLMNCEP_YR_END --val ${met_end}

# update input file location for other needed run files - this makes sure the files get stored in main output directory mapped to host computer
./xmlchange DIN_LOC_ROOT_CLMFORC=/data/site_data/
./xmlchange DIN_LOC_ROOT=/data/

# turn off debug
./xmlchange DEBUG=FALSE
./xmlchange INFO_DBUG=0

# Optimize PE layout for run
./xmlchange NTASKS_ATM=1,ROOTPE_ATM=0,NTHRDS_ATM=1
./xmlchange NTASKS_CPL=1,ROOTPE_CPL=0,NTHRDS_CPL=1
./xmlchange NTASKS_LND=1,ROOTPE_LND=0,NTHRDS_LND=1
./xmlchange NTASKS_OCN=1,ROOTPE_OCN=0,NTHRDS_OCN=1
./xmlchange NTASKS_ICE=1,ROOTPE_ICE=0,NTHRDS_ICE=1
./xmlchange NTASKS_GLC=1,ROOTPE_GLC=0,NTHRDS_GLC=1
./xmlchange NTASKS_ROF=1,ROOTPE_ROF=0,NTHRDS_ROF=1
./xmlchange NTASKS_WAV=1,ROOTPE_WAV=0,NTHRDS_WAV=1
./xmlchange NTASKS_ESP=1,ROOTPE_ESP=0,NTHRDS_ESP=1

# Set run location to case dir
./xmlchange --file env_build.xml --id CIME_OUTPUT_ROOT --val ${CASE_NAME}
# =======================================================================================


# =======================================================================================
cat >> user_nl_clm <<EOF
fsurdat = '${CLM_SURFDAT_DIR}/${CLM_USRDAT_SURDAT}'
hist_empty_htapes = .true.
hist_fincl1       = 'NEP','GPP','NPP','AGB','TOTECOSYSC','TLAI','ELAI','TSOI_10CM','QVEGT','EFLX_LH_TOT','AR',\
'HR','ED_biomass','ED_bleaf','ED_balive','DDBH_SCPF','BA_SCPF','NPLANT_SCPF','M1_SCPF','M2_SCPF',\
'M3_SCPF','M4_SCPF','M5_SCPF','M6_SCPF','GPP_BY_AGE','PATCH_AREA_BY_AGE','CANOPY_AREA_BY_AGE',\
'BA_SCLS','NPLANT_CANOPY_SCLS','NPLANT_UNDERSTORY_SCLS','DDBH_CANOPY_SCLS','DDBH_UNDERSTORY_SCLS',\
'MORTALITY_CANOPY_SCLS','MORTALITY_UNDERSTORY_SCLS','C_STOMATA','WIND','ZBOT','FSDS','RH','TBOT','PBOT','QBOT',\
'RAIN','FLDS'
hist_mfilt             = 8760
hist_nhtfrq            = -1
EOF

echo "*** Update CLM && FATES parameter files ***"
echo " "
cat >> user_nl_clm <<EOF
fates_paramfile = "${CASE_NAME}/${FATES_PARAM_FILE}"
EOF

# MODIFY THE DATM NAMELIST (DANGER ZONE - USERS BEWARE CHANGING)

cat >> user_nl_datm <<EOF
taxmode = "cycle", "cycle", "cycle"
EOF

echo "*** Running case.setup ***"
./case.setup

# HERE WE NEED TO MODIFY THE STREAM FILE (DANGER ZONE - USERS BEWARE CHANGING)
./preview_namelists
cp run/datm.streams.txt.CLM1PT.CLM_USRDAT user_datm.streams.txt.CLM1PT.CLM_USRDAT
`sed -i '/FLDS/d' user_datm.streams.txt.CLM1PT.CLM_USRDAT`

echo *** Build case ***
./case.build
 
echo "*** Finished building new case in CASE: ${CASE_NAME} "
# =============================================================================


#### EOF
