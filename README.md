# Setting up

## Fastsim

FASTSIM:
```
1. export SCRAM_ARCH=slc6_amd64_gcc530 
2. cmsrel CMSSW_8_0_10
3. cd CMSSW_8_0_10/src
4. cmsenv
5. source /cvmfs/cms.cern.ch/crab3/crab.sh
6. git clone https://github.com/dteague/Generation
7. cp -r Generation/Fastsim_Grid/ .
8. cd Fastsim_Grid
9. ./setup.sh
```
## NtupleMaker

### Can follow instructions also [here](https://github.com/florez/NtupleMaker_740/tree/for_CMSSW_8X/BSM3G_TNT_Maker)
```
1. export SCRAM_ARCH=slc6_amd64_gcc530 
2. cmsrel CMSSW_8_0_10
3. cd CMSSW_8_0_10/src
4. cmsenv
5. source /cvmfs/cms.cern.ch/crab3/crab.sh
6. git cms-init
7. git cms-addpkg RecoMET/METProducers
8 scram b -j 10
9. git cms-merge-topic -u cms-met:CMSSW_8_0_X-METFilterUpdate
10. scram b -j 10
11. git clone https://github.com/florez/NtupleMaker_740 ./NtupleMaker
12. cd NtupleMaker
13. git checkout for_CMSSW_8X 
14. cd ../
15. scram b -j 10
16. git clone https://github.com/dteague/Generation
17. cp -r Generation/nTuple_Grid/ .
18. cd Analyze_Grid
19. ./setup.sh
```
## Analyzer

```
1. export SCRAM_ARCH=slc6_amd64_gcc530 
2. cmsrel CMSSW_8_0_10
3. cd CMSSW_8_0_10/src
4. cmsenv
5. source /cvmfs/cms.cern.ch/crab3/crab.sh
6. git clone https://github.com/dteague/Analyzer
7. cd Analyzer
8. git checkout TNT80x
9. make
10. git clone https://github.com/dteague/Generation
11. cp -r Generation/Analyze_Grid/ .
12. cd Analyze_Grid
13. ./NormalSetup.sh
```

# Running Grid

Configure values (start values, number of processes, number of events in each process, number of cores) in the master.sh file

To send a task to Condor, simply type:
```
./master.sh
```

# Extra Notes

This is a guide to setting up grid generation using Condor or Slurm.  The process for setting up is the same for both and the running process is the same for both as well

For running any step, the program uses a master file that controls the output.  The master file makes no assumptions about the area one is using besides the necessary items (config files to run, storage spaces are set up, etc.).  The master file then makes necessary changes to the grid file (cmd file for Condor and slurm file for slurm) and then runs this grid file.  The grid file then invokes a runfile that does the actual work.  By this system, of master file, grid file, run file, any grid system can be inserted easily.  

Work to extending this process to CRAB3 will be done later.

But to run any step, first run the set up file or 
```
./setup.sh
```
This will set up any necessary conditions and files that will later be used.  Any changes in parameters such as number of events and processes can be changed in the master.sh file.  To send events to the cluster, just do
```
./master.sh
```
This will ask you for input such as grid password and possible configurations for the run.  
