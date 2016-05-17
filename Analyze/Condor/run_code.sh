#########################################################
#                                                       #
#  Author: Andres Florez, Universidad de los Andes, CO  #
#                                                       #
#########################################################

# The input list is passed from the run_samples_list.sh script
# Please take a look to the run_samples_list.sh for details

inputList=$1
counter=0

# Make a directory with the same name of the 
# input file process you will run over

if [ ! -d $inputList ]
then
    mkdir $inputList
fi
cp submit_condor_jobs.cmd $inputList
cp tntAnalyze.sh $inputList
cp "list_Samples/$inputList".txt  $inputList
cd $inputList 

# for loop to interate over the file samples in the list
# please take a look to the example list I have provided
# in GIT. It is imporant to use the same convention 
# to access the files "root\://cmseos.fnal.gov//"
# We can saturate the eos sever in we try to access 
# the files directly. 

for file in `cat "$inputList".txt`; do
  counter=`expr $counter + 1`
  cp submit_condor_jobs.cmd submit_${counter}.cmd
  # changes the the flag FNAME by one of the input 
  # file names in the list
  sed -i "s:FNAME:$file:g" submit_${counter}.cmd
  outfile="OutputHistos_"$counter".root"
  # changes the output name of the file.
  # each job will have aunique output file name
  sed -i "s:OUTPUTFILE:$outfile:g" submit_${counter}.cmd
  sed -i "s:OUTPUTDIR:$inputList:g" submit_${counter}.cmd
  condor_submit submit_${counter}.cmd
done
