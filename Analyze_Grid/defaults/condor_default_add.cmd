universe = vanilla
Executable=EXEC
Should_Transfer_Files = YES
WhenToTransferOutput = ON_EXIT
Output = condor_out_$(Process)_$(Cluster).stdout
Error  = condor_out_$(Process)_$(Cluster).stderr
Log    = condor_out_$(Process)_$(Cluster).log
Notification    = Error
notify_user = ${LOGNAME}@FNAL.GOV

queue
