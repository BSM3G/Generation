#!/usr/bin/env python

import multiprocessing as mp
import sys
import time
import subprocess
import pyslurm
import re
import os
import shutil
import glob

good_flags = [ 'array_task_id', 'job_state', 'run_time', 'time_limit' ]

def bins(input_file, bin_size):

    binning_list = []
    size_list = []
    name_list = []

    f = open("new_list/" + input_file + ".txt")
    for item in f:
        tmp_line = item.strip().split()
        size_list.append(int(tmp_line[0]))
        name_list.append(tmp_line[1])

    binning_size = []

    for i, sizer in enumerate(size_list):
        put = False
        name = name_list[i]
        for j, filled in enumerate(binning_size):
            if sizer + filled < bin_size:
                binning_size[j] += sizer
                binning_list[j].append(name)
                put = True
                break
        if not put:
            binning_size.append(sizer)
            tmp_list = [name]
            binning_list.append(tmp_list)
            
    return binning_list



class SampleTask(mp.Process):
    files = ""
    split = 0
    num_bins = 0
    job_num = "-1"
    binning_list=[]
    options=""
    log_out= []
    reruns = 5
    
    def __init__(self, files, split, options=""):
        self.files = files
        self.split = split
        self.binning_list = bins(self.files, self.split)
        self.num_bins = len(self.binning_list)
        self.log_out = [ ["PENDING", "0"] for i in xrange(self.num_bins)]
        self.options = options
        super(SampleTask, self).__init__()

    def AnalyzerTask(self):
        if not os.path.exists(self.files):
            os.makedirs(self.files)
        bin_file=open(self.files + "/bins.txt",'w')
        input_string=""
        for jobarray_input in self.binning_list:
            for files in jobarray_input:
                input_string+=files+" "
            input_string +="|"
        bin_file.write(input_string)
        bin_file.close()

        
        if self.options == "":
            sbatch_out = subprocess.check_output("sbatch --array=1-" + str(self.num_bins) + ' -D ' + self.files + ' run_slurm.slurm', shell=True)
        else:
            sbatch_out = subprocess.check_output("sbatch --array=1-" + str(self.num_bins) + ' -D ' + self.files + ' run_slurm.slurm "' + self.options + '"', shell=True)
        m = re.search('\w+(\d+)', sbatch_out)
        self.job_num = m.group(0)
        running_array = [i+1 for i in xrange(self.num_bins)]
        error_array = [ 0 for i in xrange(self.num_bins)]
        
        f = open(self.files+"/log.txt", 'w')
        f.write("Job ID : %s\n" % (self.job_num))
        for i, line in enumerate(self.log_out):
            f.write(str(i) + " " + line[0] + " " + line[1] + "\n")
        f.close()
            


        time.sleep(5)
        while True:
            f = open(self.files+"/tmplog.txt", 'w')
            f.write("Job ID : %s\n" % (self.job_num))
            if len(running_array) == 0:
                for i, line in enumerate(self.log_out):
                    f.write(str(i) + " " + line[0] + " " + line[1] + "\n")
                f.close()
                shutil.move(self.files + "/tmplog.txt", self.files + "/log.txt")
                break
            try:
                jobs = pyslurm.job().find_id(self.job_num)
            except ValueError:
                print "Can't find job: ", self.job_num
                break

            if jobs[0]['array_task_id'] is None:
                time.sleep(1)
                continue
            finished = True
            for item in jobs:
                array_num = item["array_task_id"]
                if array_num not in running_array:
                    continue
                if item["job_state"] == "COMPLETED":
                    running_array.remove(array_num)
                elif item["job_state"] == "FAILED":
                    if error_array[array_num-1] == self.reruns:
                        print str(array_num) + " for the job " + str(self.job_num) + " Failed after resubmissions"
                        running_array.remove(array_num)
                    else:
                        subprocess.call("scontrol requeue " + str(self.job_num)+"_"+str(array_num), shell=True)
                        error_array[array_num-1] += 1
                elif item["job_state"] == "TIMEOUT":
                        print str(array_num) + " for the job " + str(self.job_num) + " timed out"
                        running_array.remove(array_num)
                
                self.log_out[array_num - 1] = [ item["job_state"], str(item["run_time"]) ]
                if item["run_time"] > 150 and os.stat(self.files + "/output_" + str(self.job_num) + "_" + str(array_num) + ".out").st_size == 0:
                    subprocess.call("scontrol requeue " + str(self.job_num)+"_"+str(array_num), shelnl=True)

            for i, line in enumerate(self.log_out):
                f.write(str(i) + " " + line[0] + " " + line[1] + "\n")
            f.close()
            shutil.move(self.files + "/tmplog.txt", self.files + "/log.txt")
            time.sleep(5)


        print "DONE, adding", self.files
        return

    def run(self):
        print "Starting", self.files

        subp = mp.Process(target=self.AnalyzerTask)
        subp.daemon = True
        subp.start()
        subp.join()

        infiles = glob.glob(self.files+"/*.root")
        outfile = self.files

        hadd_output = self.hadd([outfile, infiles])
        if hadd_output[1] != "":
            print "ERROR in hadd for " + self.files
            print hadd_output[1]

        ###### need to add adding stuff

        return


    def hadd(self, item):
        tag,filesToAdd=item
        #time.sleep(float(randint(0,10))/10)
        out, err="",""
        doneGood=True
        if (not os.path.exists(item[0]+".root")):
            calling="hadd -f9 "+tag+".root "+" ".join(filesToAdd)
            print(calling)
            p = subprocess.Popen(calling,shell=True, stdout = subprocess.PIPE, stderr = subprocess.STDOUT )
            out, err = p.communicate()
            if ("Zombie" in out) or ("Error" in out):
                print("------------------------------------")
                print(calling)
                print("------------------------------------")
                doneGood=False
            # log.debug(out)
            # log.debug(err)
            # if doneGood:
            #     for f in filesToAdd:
            #         os.remove(f)

        return [out, err]
        

if __name__ == '__main__':

    condor_jobs = 300
    sample_list = "SAMPLES_LIST.txt"

    timeleft = -1
    try:
        timeleft = subprocess.check_output("voms-proxy-info -file ${HOME}/.x509up_u${UID} -timeleft", shell=True)
    except subprocess.CalledProcessError:
        subprocess.call("voms-proxy-init -voms cms -out ${HOME}/.x509up_u${UID}", shell=True)
    if int(timeleft) == 0:
        subprocess.call("voms-proxy-init -voms cms -out ${HOME}/.x509up_u${UID}", shell=True)

    option=""
    for i in range(1,len(sys.argv)):
        option+= sys.argv[i] + " "

    jobs = []
    input_files = []
    run_files = []

    f = open(sample_list)
    total = 0
    for filename in f:
        filename = filename.strip()
        if filename.strip() == "" or filename[0] == '#' or filename[:2] == '//':
            continue
        input_files.append(filename)

    for files in input_files:
        open_file = open("new_list/" +files + ".txt")
        for line in open_file:
            aline = line.strip().split()
            if len(aline) != 2:
                continue
            total += int(aline[0])

    split = int(1.0*total/(condor_jobs-0.01))

    for files in input_files:
        p = SampleTask(files, split, option)
        run_files.append(p)
        p.start()



