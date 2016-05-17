#!/bin/bash

for file in $(ls $CMSSW_BASE/src/CONDOR/Submit_Condor/list_Samples | xargs -n 1 basename)
do	    
    file=${file/.txt/}
    mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/$file
done



# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/TTJets_madgraphMLM_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WW_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WZ_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/ZZ_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_HT-0to100_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_HT-100to200_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_HT-200to400_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_HT-400to600_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-50_HT-600toInf_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_HT-0to100_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_HT-100to200_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_HT-200to400_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_HT-400to600_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/WJetsToLNu_HT-600toInf_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/DYJetsToLL_M-5to50_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/SingleMuon_Run2015C_ReReco_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/SingleMuon_Run2015D_PromptReco_v4_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/SingleMuon_Run2015D_ReMiniAOD_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/Tau_Run2015C_ReReco_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/Tau_Run2015D_PromptReco_v4_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/Tau_Run2015D_ReMiniAOD_25ns_MiniAODv2_December2015
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-20toInf_MuEnrichedPt15_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-120to170_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-20to30_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-30to50_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-80to120_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-170to300_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-300toInf_EMEnriched_Asympt25ns
# mkdir /eos/uscms/store/user/DUMMY/TEMPDIRECTORY/QCD_Pt-50to80_EMEnriched_Asympt25ns
