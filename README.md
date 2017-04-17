# Setting up

```
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530 
cmsrel CMSSW_8_0_10
cd CMSSW_8_0_10/src
cmsenv
git clone https://github.com/dteague/Generation
cd Generation
cp -r Analyze_Grid/ ..
cd ../Analyze_Grid
./NormalSetup.sh
```

# Running Grid

After running the Setup Script, you system is ready to run the Analyzer over the Events you want.

To send a task to Condor, simply type:
```
./master.sh
```

Configure values (start values, number of processes, number of events in each process, number of cores) in the master.sh file

To change the samples sent, put the name of the samples into the file `SAMPLES_LIST.txt`, where the names of the samples are the file names of the files in the directory `/list_Samples`.

For more information, check the [wiki page](https://github.com/BSM3G/Generation/wiki)
