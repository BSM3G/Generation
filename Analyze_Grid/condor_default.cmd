universe = vanilla
Executable=tntAnalyze.sh
Output = condor_out_$(Process)_$(Cluster).stdout
Error  = condor_out_$(Process)_$(Cluster).stderr
Log    = condor_out_$(Process)_$(Cluster).log
Notification    = Error


