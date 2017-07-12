import re
import curses
import time
from curses import wrapper
import sys

id_format = "{:>30.30}"
formating= id_format + "  | {:>11}  | {:>13}  | {:>11}  |"
start_line = 2

class Subscreen():
    subscr = None
    maxx = 0
    maxy = 0
    py = 0


class Job_Holder():
    stdscr = None
    infiles = []
    all_jobs = {}
    jobs_overview = {} # [state, id, max_run]
    colors = {"COMPLETED": 3, "FAILED": 2, "RUNNING": 1, "COMPLETING": 1}

    
    def __init__(self, sample_list="SAMPLES_LIST.txt", stdscr = None):
        self.stdscr = stdscr
        try:
            f = open(sample_list)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            print "File:", sample_list
            exit(1)
        for filename in f:
            filename = filename.strip()

            if filename.strip() == "" or filename[0] == '#' or filename[:2] == '//':
                continue

            filename += "/log.txt"
            self.infiles.append(filename)

    def set_stdscr(self, stdscr):
        self.stdscr = stdscr
        self.stdscr.scrollok(1)
        self.stdscr.idlok(1)
            
    def get_jobsize(self):
        return len(self.all_jobs)

    def refresh(self):

        for file_name in self.infiles:
            if file_name in self.jobs_overview and self.jobs_overview[file_name][0] == "COMPLETED":
                continue
            f = open(file_name, 'r')
            tmp = {}
            fill_dict = False
            job = {}
            # overview variables
            state = "COMPLETED" 
            max_time = 0
            job_id = ""
            
            for line in f:
                line = line.strip()
                m = re.search("Job ID : (\d+)", line)
                if m is not None:
                    job_id = m.group(1)
                    continue

                if line == ("-" * 80) and len(tmp) != 0:
        
                    job[tmp["array_task_id"]] = tmp
                    tmp = {}
                    continue
                line_arr = line.split()
                if len(line_arr) != 3:
                    continue
                tmp[line_arr[0]] = line_arr[2]
                if line_arr[0] == "run_time" and max_time < int(line_arr[2]):
                    max_time = int(line_arr[2])
            for item in job.values():
                tmp_state = item["job_state"]
                if tmp_state == "RUNNING" and state != "ERROR":
                    state = "RUNNING"
                elif tmp_state != "COMPLETED":
                    state = "ERROR"

            self.jobs_overview[file_name] = [state, job_id, max_time]
            self.all_jobs[file_name] = job

            
    def print_overview(self, use_id):
        cur_line = 0
        for filename, tmp_array in self.jobs_overview.iteritems():
            job_num = filename
            if use_id:
                job_num = tmp_array[1]
            array_num = "----"
            if tmp_array[0] != "COMPLETED":
                array_num = str(len(self.all_jobs[filename]))
            write_str = formating.format(job_num, array_num, tmp_array[0], tmp_array[2])
            use_color = curses.color_pair(self.colors[tmp_array[0]]) if (tmp_array[0] in self.colors) else curses.color_pair(1)
            self.stdscr.addstr(cur_line, 0, write_str, use_color | curses.A_BOLD | curses.A_UNDERLINE)
            cur_line += 1
        return cur_line

    def print_all(self, use_id):
        cur_line = 0
        for filename, job_array in self.all_jobs.iteritems():
            print cur_line
            if self.jobs_overview[filename][0] == "COMPLETED":
                tmp_array = self.jobs_overview[filename]
                job_num = filename
                if use_id:
                    job_num = self.jobs_overview[filename][1]
                write_str = formating.format(job_num, "----", tmp_array[0], tmp_array[2])
                use_color = curses.color_pair(self.colors[tmp_array[0]]) if (tmp_array[0] in self.colors) else curses.color_pair(1)
                self.stdscr.addstr(cur_line, 0, write_str, use_color | curses.A_BOLD | curses.A_UNDERLINE)
                self.stdscr.scroll(1)
                cur_line += 1
                continue
            start_job = cur_line
            for array_id, tmp_array in job_array.iteritems():

                write_str = formating.format("", array_id, tmp_array["job_state"], tmp_array["run_time"])
                use_color = curses.color_pair(self.colors[tmp_array["job_state"]]) if (tmp_array["job_state"] in self.colors) else curses.color_pair(1)
                self.stdscr.addstr(cur_line, 0, write_str, use_color | curses.A_BOLD)
                cur_line += 1
                
            job_num = filename
            if use_id:
                job_num = self.jobs_overview[filename][1]
            id_line = id_format.format(job_num)
            use_color = curses.color_pair(self.colors[self.jobs_overview[filename][0]])
            self.stdscr.addstr(start_job, 0, id_line, use_color | curses.A_BOLD)
        return cur_line







class Main_Program():
    max_line = 2
    expand = False
    use_id = False
    x = 0
    y = 0
    prev_size = 0
    
    def __init__(self, sample_list="SAMPLES_LIST.txt"):
        self.jobs = Job_Holder(sample_list)


    def header_footer(self,stdscr):
        title = formating.format("Job ID", "Array ID", "State", "Run Time")
        stdscr.addstr(0,0, title, curses.color_pair(4))
        stdscr.addstr(1,0, formating.format("","","",""), curses.A_UNDERLINE)
        options = "    q - quit    |    r - refresh    |    e - expand/contract    |    w - swap ID/Sample"
        stdscr.addstr(self.y-1, 0, options, curses.color_pair(4))
        stdscr.refresh()    

    def display_job(self):
        self.jobs.refresh()
        table_size = 0
        
        if self.expand:
            table_size = self.jobs.print_all(self.use_id)
        else:
            table_size = self.jobs.print_overview(self.use_id)

        for i in range(table_size, self.prev_size):
            self.pad.move(i, 0)
            self.pad.clrtoeol()
        self.pad.move(0,0)
        self.pad.refresh(0,0, start_line, 0, self.y-2, self.x)
        self.prev_size = table_size
        
    def main(self, stdscr):
        curses.start_color()
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_BLACK)
        self.y, self.x = stdscr.getmaxyx()
        stdscr.clear()

        self.header_footer(stdscr)
        self.jobs.refresh()
        self.pad = curses.newpad(self.jobs.get_jobsize()+5, self.x)
        self.jobs.set_stdscr(self.pad)

        self.display_job()

        while True:
            c = stdscr.getch()
            if c == ord('q'):
                break
            elif c == ord('r'):
                self.display_job()
                
            elif c == ord('e'):
                self.expand = not self.expand
                self.display_job()

            elif c == ord('w'):
                self.use_id = not self.use_id
                self.display_job()
                


if len(sys.argv) > 1:
    main = Main_Program(sys.argv[1])
else:
    main = Main_Program()
    
wrapper(main.main)
    
    

