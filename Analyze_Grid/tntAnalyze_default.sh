#!/bin/bash
date

# cd WORK_AREA
# source /cvmfs/cms.cern.ch/cmsset_default.sh
# export slc6_amd64_gcc530
# eval `scramv1 runtime -sh`

###### $1 is sample name
###### $2 is iteration
###### after is input

input_sample=$1; shift
outfilename=Output.${1}.root; shift
infilename=$@

path="/store/user/dteague/Generate/"

cd ${_CONDOR_SCRATCH_DIR}
touch ${outfilename}

echo $input_sample >> ${outfilename}
echo $outfilename>> ${outfilename}
echo ./Analyzer -out $outfilename -in ${infilename[@]} >> ${outfilename}

xrdcp -sf ${_CONDOR_SCRATCH_DIR}/$outfilename root://cmseos.fnal.gov/${path}
rm *root


# cd ${_CONDOR_SCRATCH_DIR}

# cp -r ANALYZERDIRAnalyzer/PartDet/ .
# cp -r ANALYZERDIRAnalyzer/Pileup/ .
# cp -r ANALYZERDIRAnalyzer/Analyzer .

# isData=$(echo $input_sample | grep "Run201")

# if [ ! -z $isData ]
# then
#     sed -r -i -e 's/(isData\s+)(0|false)/\1true/' -e 's/(CalculatePUS[a-z]+\s+)(1|true)/\1false/' \
# 	PartDet/Run_info.in
# else
#     sed -r -i -e 's/(isData\s+)(1|true)/\1false/' -e 's/(CalculatePUS[a-z]+\s+)(0|false)/\1true/' \
# 	PartDet/Run_info.in
# fi

# needGenWgt=$(echo $input_sample | grep -E 'powheg|amcatnlo')
# if [ ! -z $needGenWgt ]
# then
#     sed -r -i 's/(ApplyGenWeight\s+)(0|false)/\1true/' PartDet/Run_info.in
# else
#     sed -r -i 's/(ApplyGenWeight\s+)(1|true)/\1false/' PartDet/Run_info.in
# fi

# ./Analyzer -in $infilename -out $outfilename

# xrdcp -sf $_CONDOR_SCRATCH_DIR/$outfilename root://cmseos.fnal.gov//store/user/DUMMY/TEMPDIRECTORY/$input_sample

# rm Analyzer
# rm -r PartDet
# rm -r Pileup
# rm *root











