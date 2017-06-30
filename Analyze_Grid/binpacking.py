import luigi
import os
import subprocess
import re
import time
import luigi.cmdline as lc

class AnalyzerTask(luigi.Task):
    iteration=luigi.IntParameter(default=0)
    input_file = luigi.Parameter()
    lister = []
    condor_id = -1

    def run(self):
        while len(self.lister) == 0:
            return
        input_str = self.input_file + " " + str(self.iteration)
        for item in self.lister:
            input_str += " " + item
        con_out = subprocess.check_output("condor_submit -append \" args = " + input_str + " \" run_condor.cmd -queue 1", shell=True)
        
        p = re.compile('^\d+ job\(s\) submitted to cluster (\d+)\.', re.MULTILINE)
        tmp_con_out = con_out.split('\n')
        for i in tmp_con_out:
            if p.match(i) != None:
                self.condor_id = p.match(i).group(1)
                break
        done = False
        while not done:
            try:
                print subprocess.check_output("condor_q dteague | grep " + self.condor_id, shell=True)
                time.sleep(5)
            except subprocess.CalledProcessError as grepexc:
                print "DONE"
                done = True
#        found_file = False
        # while no found_file:
        #     try:
        #         print subprocess.check_output("ls | grep " + condor_id, shell=True)
        #         time.sleep(5)
        #     except subprocess.CalledProcessError as grepexc:
        #         print "DONE"
        #         done = True

    def complete(self):
        if self.condor_id == -1: return False
        try:
            print subprocess.check_output("condor_q dteague | grep " + str(self.condor_id), shell=True)
            return False
        except subprocess.CalledProcessError as grepexc:
            print "DONE"
            return True
        
        

    def output(self):
        return luigi.LocalTarget(self.getOutname())

    def setList(self, lister):
        self.lister = list(lister)
        
    def getOutname(self):
        return "/eos/uscms/store/user/dteague/Generate/Output." + str(self.iteration) + ".root"



class FileTask(luigi.Task):
    input_file = luigi.Parameter()
    bin_size = luigi.IntParameter()
    setup_files = False
    binning_list = []

    def output(self):
        return luigi.LocalTarget(str(self.input_file) + ".root")

    def setup_files_func(self):
        size_list = []
        name_list = []
      
        f = open("new_list/" + self.input_file + ".txt")
        for item in f:
            tmp_line = item.strip().split()
            size_list.append(int(tmp_line[0]))
            name_list.append(tmp_line[1])

        binning_size = []

        for i, sizer in enumerate(size_list):
            put = False
            name = name_list[i]
            for j, filled in enumerate(binning_size):
                if sizer + filled < self.bin_size:
                    binning_size[j] += sizer
                    self.binning_list[j].append(name)
                    put = True
                    break
            if not put:
                binning_size.append(sizer)
                tmp_list = [name]
                self.binning_list.append(tmp_list)


    def requires(self):
        if not self.setup_files:
            self.setup_files_func()
            self.setup_files = True
        tmplist = [ AnalyzerTask(iteration=i, input_file=self.input_file) for i in xrange(len(self.binning_list))]
        print tmplist
        for i, item in enumerate(list(tmplist)):
            item.setList(self.binning_list[i])
        return tmplist


    def run(self):
        infiles = ""
        for item in self.requires():
            infiles += item.getOutname() + " "
        os.system("cat " + infiles + " > " + str(self.input_file) + ".root")





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
        split = 1.0*total/(self.condor_jobs-0.1)
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
               









