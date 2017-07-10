import luigi
import os
import subprocess
import re
import time
import luigi.cmdline as lc

# class AnalyzerTask(luigi.Task):
#     iteration=luigi.IntParameter(default=0)
#     input_file = luigi.Parameter()
#     lister = []
#     slurm_id = -1

#     def run(self):
#         while len(self.lister) == 0:
#             return
#         input_str = self.input_file + " " + str(self.iteration)
#         for item in self.lister:
#             input_str += " " + item
#         sbatch_out = subprocess.check_output("sbatch run_slurm.slurm " + input_str , shell=True)
#         m = re.search('\w+(\d+)', sbatch_out)

#         self.slurm_id = int(m.group(0))
#         print self.slurm_id
#         # while no found_file:
#         #     try:
#         #         print subprocess.check_output("ls | grep " + condor_id, shell=True)
#         #         time.sleep(5)
#         #     except subprocess.CalledProcessError as grepexc:
#         #         print "DONE"
#         #         done = True

#     def complete(self):
#         if self.slurm_id == -1: 
#             print "here"
#             return False
#         try:
#             print subprocess.check_output("squeue -u teaguedo -o '%.18i %.2t %.8M' | grep " + str(self.slurm_id), shell=True)
#             print "sleeping"
#             time.sleep(5)
#         except subprocess.CalledProcessError as grepexc:
#             my_file = Path(self.getOutname)
#             if my_file.is_file():
#                 print "DONER"
#                 return True
#             else:
#                 return False

#     def output(self):
#         return luigi.LocalTarget(self.getOutname())

#     def setList(self, lister):
#         self.lister = list(lister)
        
#     def getOutname(self):
#         return "/cms/store/user/teaguedo/Output." + str(self.iteration) + ".root"



class FileTask(luigi.Task):
    input_file = luigi.Parameter()
    bin_size = luigi.IntParameter()

    def output(self):
        return luigi.LocalTarget(self.input_file + ".root")

    def run(self):
        num_bins = int(subprocess.check_output("./sort.py " + self.input_file + " " + str(self.bin_size) + " bins",shell=True))
        print self.bin_size, num_bins
        f = open(self.input_file + ".root", 'w')


    # def setup_files_func(self):
    #     self.binning_list = []
    #     size_list = []
    #     name_list = []
      
    #     f = open("new_list/" + self.input_file + ".txt")
    #     for item in f:
    #         tmp_line = item.strip().split()
    #         size_list.append(int(tmp_line[0]))
    #         name_list.append(tmp_line[1])

    #     binning_size = []

    #     for i, sizer in enumerate(size_list):
    #         put = False
    #         name = name_list[i]
    #         for j, filled in enumerate(binning_size):
    #             if sizer + filled < self.bin_size:
    #                 binning_size[j] += sizer
    #                 self.binning_list[j].append(name)
    #                 put = True
    #                 break
    #         if not put:
    #             binning_size.append(sizer)
    #             tmp_list = [name]
    #             self.binning_list.append(tmp_list)


    # def requires(self):
    #     if not self.setup_files:
    #         print "SHOULD ONLY BE ONCE"
    #         self.setup_files_func()
    #         self.setup_files = True
    #     tmplist = [ AnalyzerTask(iteration=i, input_file=self.input_file) for i in xrange(len(self.binning_list))]
    #     print tmplist
    #     for i, item in enumerate(list(tmplist)):
    #         item.setList(self.binning_list[i])
    #     print "in this require"
    #     return tmplist


    # def run(self):
    #     infiles = ""
    #     for item in self.requires():
    #         infiles += item.getOutname() + " "
    #     os.system("cat " + infiles + " > " + str(self.input_file) + ".root")



class MainTask(luigi.Task):
    sample_list = luigi.Parameter(default="SAMPLES_LIST.txt")
    condor_jobs = luigi.IntParameter(default=10)

    def requires(self):
        input_files = []
        f = open(self.sample_list)
        total = 0
        for filename in f:
            filename = filename.strip()
            if filename.strip() == "" or filename[0] == '#' or filename[:2] == '//':
                continue
            input_files.append(filename)
            total += int(subprocess.check_output("cat new_list/"+filename+".txt | awk '{i+=$1}END{print i}'", shell=True))
        split = int(1.0*total/(self.condor_jobs-0.1))
        return [ FileTask(input_file=filename, bin_size=split) for filename in input_files ]


if __name__ == "__main__":
    # input_files = []
    # f = open("SAMPLES_LIST.txt")
    # total = 0
    # for filename in f:
    #     filename = filename.strip()
    #     if filename.strip() == "" or filename[0] == '#' or filename[:2] == '//':
    #         continue
    #     input_files.append(filename)
    #     print "cat new_list/"+filename+".txt | awk '{i+=$1}END{print i}'"
    #     total += int(subprocess.check_output("cat new_list/"+filename+".txt | awk '{i+=$1}END{print i}'", shell=True))

    # print "$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    # print total
    # print "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"

    # lc.luigid(["--background", "--pidfile", "PID", "--logdir", "LOG"])
    luigi.run()
               









