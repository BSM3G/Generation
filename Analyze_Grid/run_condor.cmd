universe = vanilla
Executable=tntAnalyze_default.sh
Output = condor_out_$(Process)_$(Cluster).stdout
Error  = condor_out_$(Process)_$(Cluster).stderr
Log    = condor_out_$(Process)_$(Cluster).log
Notification    = Error


