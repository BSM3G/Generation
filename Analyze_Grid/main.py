import multiprocessing as mp
import sys
import time
import subprocess
import pyslurm
import re
import os

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

    def __init__(self, files, split, options=""):
        self.files = files
        self.split = split
        self.binning_list = bins(self.files, self.split)
        self.num_bins = len(self.binning_list)
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
        
        sbatch_out = subprocess.check_output("sbatch --array=1-" + str(self.num_bins) + ' -D ' + self.files + ' run_slurm.slurm "' + self.options + '"', shell=True)
        m = re.search('\w+(\d+)', sbatch_out)
        self.job_num = m.group(0)
        running_array = [i+1 for i in xrange(self.num_bins)]
        
        f = open(self.files+"/log.txt", 'w')
        f.write("Job ID : %s\n" % (self.job_num))
        while True:
            if len(running_array) == 0:
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
                if int(item["array_task_id"]) not in running_array:
                    continue
                if item["job_state"] == "COMPLETE":
                    running_array.remove(item["array_task_id"])
                for part_key in good_flags:
                    f.write("\t%-20s : %s\n" % (part_key, item[part_key]))
                f.write( "-" * 80 + "\n")
            f.flush()
            time.sleep(5)
        f.write("Done")
        f.close()
        print "DONE, adding", self.files
        return

    def run(self):
        print "Starting", self.files

        subp = mp.Process(target=self.AnalyzerTask)
        subp.daemon = True
        subp.start()
        subp.join()
        ###### need to add adding stuff

        return


        

if __name__ == '__main__':

    condor_jobs = 100
    sample_list = "SAMPLES_LIST.txt"
    
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



