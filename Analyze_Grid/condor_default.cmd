universe = vanilla
Executable=tntAnalyze.sh
Output = condor_out_$(Process)_$(Cluster).stdout
Error  = condor_out_$(Process)_$(Cluster).stderr
Notification    = Error
509userproxy =/tmp/x509up_u49952

