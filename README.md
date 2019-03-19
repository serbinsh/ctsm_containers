# ctsm_containers

A repository of CTSM containers

Docker hub: https://hub.docker.com/r/serbinsh/ctsm_containers

Singularity-hub location: https://www.singularity-hub.org/collections/2486

GitHub source code location: https://github.com/serbinsh/ctsm_containers

Evolving Wiki page: https://github.com/serbinsh/ctsm_containers/wiki


<br>

<br>

### Example single site test run at US-NR1 (Niwot Ridge, Colorado)

1) Install the Docker engine: https://www.docker.com/get-started

<br>

2) Pull down the latest version of the basic CTSM Docker container <br>
```docker pull serbinsh/ctsm_containers:ctsm-release-clm5.0.15```

<br>

3) Setup and run the docker container to develop the CTSM (CLM5) example case at US-NR1
Options:
output folder on the host and container: ~/scratch:/ctsm_output
Start year: '1998-01-01'
Number of run years: 2

```
docker run -t -i --hostname=modex --user clmuser -v ~/Data/cesm_input_data:/data -v ~/scratch:/ctsm_output serbinsh/ctsm_containers:ctsm-release-clm5.0.15 /ctsm_run_scripts/create_case_1pt_example_USNR1.sh '1998-01-01' 2
```

This will start building the case, example:

```
130-199-9-234:~ sserbin$ docker run -t -i --hostname=modex --user clmuser -v ~/Data/cesm_input_data:/data -v ~/scratch:/ctsm_output serbinsh/ctsm_containers:ctsm-release-clm5.0.15 /ctsm_run_scripts/create_case_1pt_example_USNR1.sh '1998-01-01' 2
/ctsm_run_scripts
Start year: 1998-01-01
Number of years: 2
*** start: 1552924779
*** Building CASE: /ctsm_output/CLM5_1552924779
Running with CTSM location: /ctsm
Compset longname is 2000_DATM%GSWP3v1_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV
Compset specification file is /ctsm/cime/../cime_config/config_compsets.xml
Compset forcing is 1972-2004
ATM component is  Data driven ATM  GSWP3v1 data set
LND component is clm5.0:BGC (vert. resol. CN and methane) with prognostic crop:
ICE component is Stub ice component
OCN component is Stub ocn component
ROF component is MOSART: MOdel for Scale Adaptive River Transport
GLC component is Stub glacier (land ice) component
WAV component is Stub wave component
ESP component is
Pes     specification file is /ctsm/cime/../cime_config/config_pes.xml
Machine is modex
Pes setting: grid match    is l%0.9x1.25
Pes setting: grid          is a%0.9x1.25_l%0.9x1.25_oi%null_r%r05_g%null_w%null_m%gx1v6
Pes setting: compset       is 2000_DATM%GSWP3v1_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV
Pes setting: tasks       is {'NTASKS_ATM': -4, 'NTASKS_ICE': -4, 'NTASKS_CPL': -4, 'NTASKS_LND': -4, 'NTASKS_WAV': -4, 'NTASKS_ROF': -4, 'NTASKS_OCN': -4, 'NTASKS_GLC': -4}
Pes setting: threads     is {'NTHRDS_ICE': 1, 'NTHRDS_ATM': 1, 'NTHRDS_ROF': 1, 'NTHRDS_LND': 1, 'NTHRDS_WAV': 1, 'NTHRDS_OCN': 1, 'NTHRDS_CPL': 1, 'NTHRDS_GLC': 1}
Pes setting: rootpe      is {'ROOTPE_OCN': 0, 'ROOTPE_LND': 0, 'ROOTPE_ATM': 0, 'ROOTPE_ICE': 0, 'ROOTPE_WAV': 0, 'ROOTPE_CPL': 0, 'ROOTPE_ROF': 0, 'ROOTPE_GLC': 0}
Pes setting: pstrid      is {}
Pes other settings: {}
Pes comments: none
 Compset is: 2000_DATM%GSWP3v1_CLM50%BGC-CROP_SICE_SOCN_MOSART_SGLC_SWAV
 Grid is: a%0.9x1.25_l%0.9x1.25_oi%null_r%r05_g%null_w%null_m%gx1v6
 Components in compset are: ['datm', 'clm', 'sice', 'socn', 'mosart', 'sglc', 'swav', 'sesp', 'drv', 'dart']
No project info available
No charge_account info available, using value from PROJECT
No project info available
cesm model version found: release-clm5.0.15
Batch_system_type is none
 Creating Case directory /ctsm_output/CLM5_1552924779
*** Switching directory to CASE: /ctsm_output/CLM5_1552924779
...
```

Take note of the auto-generated output folder in ~/scratch **CLM5_1552924779**

<br>

4) Once the build is finished, run the case:

```
docker run -t -i --hostname=modex --user clmuser -v ~/Data/cesm_input_data:/data -v ~/scratch:/ctsm_output serbinsh/ctsm_containers:ctsm-release-clm5.0.15 /bin/sh -c 'cd /ctsm_output/CLM5_1552924779/ && ./case.submit'
```

<br>

5) Explore the outputs!
