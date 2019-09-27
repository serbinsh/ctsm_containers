#!/bin/bash

#WORKDIR=/ctsm_run_scripts/
#cd $WORKDIR
echo $PWD

# Set simulation options by named flag or use defaults if missing
for i in "$@"
do
case $i in
    -cr=*|--case_root=*)
    case_root="${i#*=}"
    shift # past argument=value
    ;;
    -sn=*|--site_name=*)
    site_name="${i#*=}"
    shift # past argument=value
    ;;
    -dd=*|--datm_data=*)
    datm_data="${i#*=}"
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
site_name="${site_name:-CLM5_site_run}"
datm_data="${datm_data:-/data}"
start_year="${start_year:-'2008-01-01'}"
num_years="${num_years:-2}"
rtype="${rtype:-startup}"
met_start="${met_start:-2008}"
met_end="${met_end:-2016}"

# show options
echo "CASEROOT location = ${case_root}"
echo "Site Name = ${site_name}"
echo "DATM data source = ${datm_data}"
echo "Model simulation start year  = ${start_year}"
echo "Number of simulation years  = ${num_years}"
echo "Run type = ${rtype}"
echo "DATM_CLMNCEP_YR_START: "${met_start}
echo "DATM_CLMNCEP_YR_END: "${met_end}

# Setup simulation case
export SITE_NAME=${site_name}							                # which site?
export MODEL_SOURCE=/ctsm						                        # don't change, location in the container
export MODEL_VERSION=CLM5						                        # info tag
export CLM_HASH=`(cd ${MODEL_SOURCE};git log -n 1 --pretty=%h)`		    # info tag
export CIME_MODEL=cesm							                        # which CIME model
export MACH=${HOSTNAME}							                        # docker container hostname
export RES=CLM_USRDAT							                        # 1pt
export COMP=2000_DATM%GSWP3v1_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV	# compset
export CASEROOT=${case_root}						                    # Container/model output location.  Can be redirected to a different location on the host
export date_var=$(date +%s)						                        # auto info tag
export CASE_NAME=${CASEROOT}/${MODEL_VERSION}_${date_var}_${site_name}	# Output directory name

# Define CLM5 parameter file here:
export CLM5_PARAM_FILE_PATH=/ctsm_parameter_files
export CLM5_PARAM_FILE=clm5_params.c171117.nc

# Define forcing and surfice file data for run:
export datmdata_dir=${datm_data}/datmdata/atm_forcing.datm7.GSWP3.0.5d.v1.c170516
echo "DATM forcing data directory:"
echo ${datmdata_dir}

pattern=${datmdata_dir}/"domain.lnd.360x720_*"
datm_domain_lnd=( $pattern )
echo "DATM land domain file:"
echo "${datm_domain_lnd[0]}"
export CLM5_DATM_DOMAIN_LND=datm_domain_lnd

pattern=${datm_data}/"domain.lnd*"
domain_lnd=( $pattern )
echo "Land domain file:"
echo "${domain_lnd[0]}"
export CLM5_USRDAT_DOMAIN=domain_lnd

pattern=${datm_data}/"surfdata_*"
surfdata=( $pattern )
echo "Surface file:"
echo "${surfdata[0]}"
export CLM5_SURFDAT=surfdata

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
echo "*** Copy CLM5 parameter file ***"
echo " "
cp ${CLM5_PARAM_FILE_PATH}/${CLM5_PARAM_FILE} .
# =======================================================================================

# =======================================================================================
echo "*** Modifying xmls  ***"

## need to revist these options
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
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val ${CASE_NAME}/history
./xmlchange --file env_run.xml --id RUNDIR --val ${CASE_NAME}/run
./xmlchange --file env_build.xml --id EXEROOT --val ${CASE_NAME}/bld

# domain options
./xmlchange -a CLM_CONFIG_OPTS='-nofire'
./xmlchange ATM_DOMAIN_FILE=${CLM5_USRDAT_DOMAIN}
./xmlchange LND_DOMAIN_FILE=${CLM5_USRDAT_DOMAIN}
./xmlchange ATM_DOMAIN_PATH=${datm_data}/${site_name}
./xmlchange LND_DOMAIN_PATH=${datm_data}/${site_name}
./xmlchange CLM_USRDAT_NAME=${site_name}
./xmlchange MOSART_MODE=NULL

# met options
./xmlchange --id DATM_CLMNCEP_YR_START --val ${met_start}
./xmlchange --id DATM_CLMNCEP_YR_END --val ${met_end}


#### EOF