This is a guide to setting up grid generation using Condor or Slurm.  The process for setting up is the same
for both and the running process is the same for both as well

For running any step, the program uses a master file that controls the output.  The master file makes no 
assumptions about the area one is using besides the necessary items (config files to run, storage spaces are set
up, etc.).  The master file then makes necessary changes to the grid file (cmd file for Condor and slurm file for 
slurm) and then runs this grid file.  The grid file then invokes a runfile that does the actual work.  By this 
system, of master file, grid file, run file, any grid system can be inserted easily.  

Work to extending this process to CRAB3 will be done later.

But to run any step, first run the set up file or 

./setup.sh

This will set up any necessary conditions and files that will later be used.  Any changes in parameters such as 
number of events and processes can be changed in the master.sh file.  To send events to the cluster, just do

./master.sh

This will ask you for input such as grid password and possible configurations for the run.  Any other dependent
files needed to run are specified in the instructions below:



FASTSIM:

1. export SCRAM_ARCH=slc6_amd64_gcc491 (or setenv SCRAM_ARCH slc6_amd64_gcc491)
2. cmsrel CMSSW_7_4_15
3. cd CMSSW_7_4_15/src
4. cmsenv
5. source /cvmfs/cms.cern.ch/crab3/crab.sh
6. git clone https://github.com/dteague/Generation
7. mkdir Fastsim_Grid
8. cp -r Generation/Fastsim/Slurm/* Fastsim_Grid
9. cd Fastsim_Grid
10. ./setup.sh

After this, the files are ready to run.  Just change the necessary parameters in master.sh
logfiles will have output of slurm, pythia, and the used cfg files for running each event
AODSIM and miniAOD will house the root files for their respective types

nTuple:

1. export SCRAM_ARCH=slc6_amd64_gcc491 (or setenv SCRAM_ARCH slc6_amd64_gcc491)
2. cmsrel CMSSW_7_4_15
3. cd CMSSW_7_4_15/src
4. cmsenv
5. source /cvmfs/cms.cern.ch/crab3/crab.sh
6. git cms-merge-topic ikrav:egm_id_7.4.12_v1
7. scram b -j 10
8. git clone https://github.com/florez/NtupleMaker_740
9. cd NtupleMaker_740
10. git checkout miniAODv2_ForHiggsDalitz
11. cd ./..
12. mv NtupleMaker_740 NtupleMaker
13. scram b -j 10
14. git clone https://github.com/dteague/Generation
15. mkdir nTuple_Grid
15. cp -r Generation/nTuple/Slurm/* nTuple_Grid
16. ./setup.sh