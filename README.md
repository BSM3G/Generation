# Table of Contents
1. [Setup](#setup)
2. [Run Fastsim](#run-fastsim)
3. [Run NtupleMaker](#run-ntuplemaker)
4. [Run Analyzer](#run-analyzer)
   - [Basic Run](#basic-run)
   - [Deleting Files](#deleting-files)
   - [Adding Files](#adding-files)

# Setup

- for Vanderbilt Accre: CMSSW [version 74x](https://github.com/BSM3G/Generation/tree/Slurm74x) or [version 80x](https://github.com/BSM3G/Generation/tree/Slurm80x)
- for LPC at FNAL: CMSSW [version 74](https://github.com/BSM3G/Generation/tree/Condor74x) or [version 80x](https://github.com/dteague/BSM3G/tree/Condor80x)

# Run Fastsim

_Coming Soon!_
This works on the basic idea of setup with ```./setup.sh```, configure the run in master.sh and run it by ```./master.sh``` But full instructions will come soon.

# Run NtupleMaker

_Coming Soon!_
This works on the basic idea of setup with ```./setup.sh```, configure the run in master.sh and run it by ```./master.sh``` But full instructions will come soon.

# Run Analyzer

## Basic Run

To set up the script, simply go into your Analyze_Grid directory and do a setup:
```
cd /path/to/Analyze_Grid
./NormalSetup
```
This will prompt you with some choices.  Simply enter the number of your choice and it will set up your eos area to put files and running files.  You will notice the file makes 4 new files:
```
ls -t | head -n4
> addingRoot.sh
> tntAnalyze.sh
> deleteEOSAnalysisRootFiles.sh
> SAMPLES_LIST_MC.txt
```
Before you send your tasks, if you are running Monte Carlo Simulations, check SAMPLES_LIST_MC.txt as it will have a list of all the samples that will be analyzed on the gird.  Remove any that are unnecessary as all MC samples available are in this list

To send the task to the Grid, simply type
```
./master.sh
```
In the master.sh file you will see some configurable items:
```
limit=200 
stepsize=100   ###CONDOR ONLY
runfile=tntAnalyze.sh   ###CONDOR ONLY
```
Limit    - the number of allowed tasks allowed to run on the grid
stepsize - max number of tasks sent to CONDOR
runfile  - variable with the runfile used by the grid

## Deleting Files

After making a run, you will now have many log directories and root files in you eos area.  To clear each respectively, you have two scipts that take care of deletion for you:
```
./deleteEOSAnalysisRootFile.sh
./deleteLocalLogFileDirectories.csh
```
After that is done, your system is clear and can run another set of files.

## Adding Files
Once a task has been run, you will need to check that the root files have no error, add the root files, and then get the cut flow efficiency from the output.  This can be taken care of with 2 commands
```
./finish.sh > <YOUR OUTPUT FILE>  #puts cut flow efficiency in the output file.  Crashes if error in a run.
./addingRoot.sh
```
After that is done, you will have an output file with the cutflow and a root file for each task in SAMPLES_LIST.txt.
