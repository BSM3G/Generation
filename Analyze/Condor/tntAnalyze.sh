#########################################################
#                                                       #
#  Author: Andres Florez, Universidad de los Andes, CO  #
#                                                       #
#########################################################

#!/bin/bash
# These input parameters are going to be passed to the 
# script from the submit_condor_jobs.cmd script, 
# which takes the input from the run_code.sh 
 
fname=$1
outputfile=$2
outputdir=$3

date

echo $fname

# You need to set the enviroment to get ROOT 
# You need to modify the lines below to point to your
# CMSSW area. 
#Also, please read the carefully the comments below.

# "cd" to the are where you have installed your CMSSW release, e.g:
# e.g. cd /uscms_data/d3/florez/TagAndProbe_BSM3G_TNT_Analyzer/CMSSW_7_4_1/src

cd /uscms_data/d3/dteague/CMSSW_7_4_15/src/
. /cvmfs/cms.cern.ch/cmsset_default.sh
eval `scram runtime -sh`
echo $_CONDOR_SCRATCH_DIR
cd ${_CONDOR_SCRATCH_DIR}

# Copy the directory where you have the compiled code, e.g.:
# cp -r /uscms_data/d3/florez/TagAndProbe_BSM3G_TNT_Analyzer/CMSSW_7_4_1/src/Fermilab_TauHAT2015/muonToTauFakeRate . 
cp -r /uscms_data/d3/dteague/CMSSW_7_4_15/src/Analyzer/BSM3G_TNT_MainAnalyzer/VBFTauTauTau .

# "cd" in to the analysos code directory, e.g:
# cd muonToTauFakeRate
cd VBFTauTauTau
./BSM3GAnalyzer $fname $outputfile

echo "LIST BEFORE MOVING"
ls ${_CONDOR_SCRATCH_DIR}

# Also, and very important: You need to create directories in eos
# with matching names to those is the lists (Ntuples_DYtoLL_Spring15)
# The reason why I am sending the output to EOS is because someone told me at fermilab 
# that when submmiting a large number of jobs we can saturate the EOS system by 
# copying files directly and no with the xrdcp convention, which I think 
# it allows the system handle jobs according to how busy it is....
# if you can to copy the files directly, you can modify the line below
# but you get yell at, I warned you :) 

#Copy the output to your EOS area, e.g:
#xrdcp $_CONDOR_SCRATCH_DIR/muonToTauFakeRate/$outputfile  root://cmseos.fnal.gov//store/user/florez/TNT_Analyzer_Condor/$outputdir

xrdcp -sf $_CONDOR_SCRATCH_DIR/VBFTauTauTau/$outputfile root://cmseos.fnal.gov//store/user/dteague/Analysis_3Tau/$outputdir

cd ${_CONDOR_SCRATCH_DIR}
rm -rf VBFTauTauTau

echo "List after moving/removing everything"
ls ${_CONDOR_SCRATCH_DIR}

date
