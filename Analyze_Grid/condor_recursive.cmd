universe = vanilla
Executable=../run_adding.sh
Output = condor_out_$(Process)_$(Cluster).stdout
Error  = condor_out_$(Process)_$(Cluster).stderr
Notification    = Error


