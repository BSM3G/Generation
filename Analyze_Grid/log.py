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
    total_jobs = 0
    prev_updown = 0
    highlight=0
    highlight_p = 0
    py = 0
    colors = {"COMPLETED": 3, "FAILED": 2, "ERROR": 2,  "RUNNING": 1, "COMPLETING": 1, "PENDING": 5, "TIMEOUT": 2}
    single_scrolling = False
    
    def __init__(self, y, x, total_jobs):
        self.maxx = x
        self.maxy = y
        self.subscr = curses.newpad(y, x)
        self.total_jobs = total_jobs

    def correct_highp(self):
        if self.highlight_p >= self.py + self.maxy:
            self.py = self.highlight_p
        elif self.highlight_p < self.py:
            self.py = self.highlight_p
            
    def display_page(self, item_array):
        start=0
        position=0
        high_id=""
        if not self.single_scrolling:
            for i, line in enumerate(item_array):
                m=re.search("\A\s*((\w|-)+)  \|", item_array[i])
                if m is not None:
                    if self.highlight == start:
                        self.highlight_p = i
                        high_id = m.group(1)
                        break
                    start += 1
            self.correct_highp()
        else:
            if self.highlight_p >= len(item_array):
                self.highlight_p = len(item_array)-1
            m=re.search("\A(\s|-|\w)+\|\s+(\d+)  \|", item_array[self.highlight_p])
            high_id=m.group(1)
            m=re.search("\A\s*((\w|-)+)  \|", item_array[self.highlight_p])
            if m is not None:
                self.highlight += self.prev_updown

            
        for i in xrange(self.maxy):
            if i+self.py < len(item_array):
                color = curses.color_pair(1)
                m = re.search(r'\b([A-Z]+)\b', item_array[i+self.py])
                if m is not None: color = curses.color_pair(self.colors[m.group(0)])
                self.subscr.addstr(i, 0, item_array[i+self.py], color)
            else:
                self.subscr.addstr(i, 0, " " * 80)

            
        if len(high_id) <= 30:
            self.subscr.addstr(self.highlight_p-self.py, 30-len(high_id), high_id, curses.A_STANDOUT)
        else:
            self.subscr.addstr(self.highlight_p-self.py, 0, id_format.format(high_id), curses.A_STANDOUT)
        self.subscr.refresh(0,0,start_line, 0, self.maxy-start_line, self.maxx)

    def job_scroll(self, updown):
        self.single_scrolling = False
        if self.highlight+updown < 0:
            return
        elif self.highlight+updown >= self.total_jobs:
            return
        
        self.highlight += updown

    def single_scroll(self, updown):
        self.single_scrolling = True
        self.highlight_p += updown
        self.prev_updown = updown
        self.correct_highp()
        
    def set_job_scroll(self):
        self.single_scrolling = False
        
        
class Job_Holder():
    stdscr = None
    infiles = []
    all_jobs = {} #  [ state, time ]
    jobs_overview = {} # [state, id, max_run]
    
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

            
    def get_jobsize(self):
        return len(self.all_jobs)

    def refresh(self):

        for file_name in self.infiles:
            if file_name in self.jobs_overview and self.jobs_overview[file_name][0] == "COMPLETED":
                continue
            f = open(file_name, 'r')

            job_id = -1
            max_time = 0
            job_array = []
            for line in f:
                line = line.strip()
                if job_id == -1:
                    m = re.search("Job ID : (\d+)", line)
                    if m is not None:
                        job_id = int(m.group(1))
                        continue
                    continue
                line_arr = line.split()
                if len(line_arr) != 3:
                    continue
                job_array.append( [ line_arr[1], line_arr[2] ])
                if int(line_arr[2]) > max_time:
                    max_time = int(line_arr[2])
            overall_state = "COMPLETED"
            for item in job_array:
                tmp_state = item[0]
                if tmp_state == "FAILED":
                    overall_state = "ERROR"
                    break
                if tmp_state != "COMPLETED":
                    overall_state = "RUNNING"
            self.all_jobs[file_name] = job_array
            self.jobs_overview[file_name]  = [overall_state, str(job_id), str(max_time)]
            
    def overview_array(self, use_id):
        return_array = []
        for filename, tmp_array in self.jobs_overview.iteritems():
            job_num = filename
            if use_id:
                job_num = tmp_array[1]
            array_num = "----"
            if tmp_array[0] != "COMPLETED":
                array_num = str(len(self.all_jobs[filename]))
            write_str = formating.format(job_num, array_num, tmp_array[0], tmp_array[2])
            return_array.append(write_str)
        return return_array

    def all_array(self, use_id, show_complete):
        return_array = []
        for filename, job_array in self.all_jobs.iteritems():
            if self.jobs_overview[filename][0] == "COMPLETED":
                tmp_array = self.jobs_overview[filename]
                job_num = filename
                if use_id:
                    job_num = self.jobs_overview[filename][1]
                write_str = formating.format(job_num, "----", tmp_array[0], tmp_array[2])
                return_array.append(write_str)
                continue

            first = True
            for array_id, tmp_array in enumerate(job_array):
                array_id += 1
                write_str = ""
                if not show_complete and tmp_array[0] == "COMPLETED":
                    continue
                if first:
                    job_num = filename
                    if use_id:
                        job_num = self.jobs_overview[filename][1]
                    write_str = formating.format(job_num, array_id, tmp_array[0], tmp_array[1])
                    first = False
                else:
                    write_str = formating.format("", array_id, tmp_array[0], tmp_array[1])
                return_array.append(write_str)
        return return_array

    def get_total_jobs(self):
        return len(self.jobs_overview)
    
class Main_Program():
    max_line = 2
    expandall = False
    use_id = False
    show_complete = True
    prev_size = 0
    maxy = 0
    maxx = 0
    pad=None
    start_time= 0
    
    def __init__(self, sample_list="SAMPLES_LIST.txt"):
        self.jobs = Job_Holder(sample_list)


    def header_footer(self,stdscr):
        title = formating.format("Job ID", "Array ID", "State", "Run Time")
        stdscr.addstr(0,0, title, curses.color_pair(4))
        stdscr.addstr(1,0, formating.format("","","",""), curses.A_UNDERLINE)
        options = ["q - quit", "r - refresh", "e - expand", "w - swap ID/Sample", "h - toggle complete", "j/k - move individual", "n/p - move job" ] 
        First = True
        footer_line = []
        tmp_footer=""
        spacer = 3
        for line in options:
            line = " "*spacer + line + " "*spacer
            if len(tmp_footer)+len(line) < self.maxx:
                if not First:
                    tmp_footer += "|"
                else: First = False
                tmp_footer += line
            else:
                footer_line.append(tmp_footer)
                tmp_footer = line
        footer_line.append(tmp_footer)
        for i, line in enumerate(footer_line):
            stdscr.addstr(self.maxy-len(footer_line)+i, 0, line, curses.color_pair(4))

        stdscr.refresh()    
        return len(footer_line)
        
    def display_pad(self):
        self.jobs.refresh()
        if self.expandall:
            self.pad.display_page(self.jobs.all_array(self.use_id, self.show_complete))
        else:
            self.pad.display_page(self.jobs.overview_array(self.use_id))
        
    def main(self, stdscr):
        curses.start_color()
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        self.maxy, self.maxx = stdscr.getmaxyx()
        stdscr.clear()

        
        lower_line_size = self.header_footer(stdscr)
        self.jobs.refresh()
        self.pad = Subscreen(self.maxy - lower_line_size + 1, self.maxx, self.jobs.get_total_jobs())
        self.display_pad()

        curses.halfdelay(5)
        while True:
            self.display_pad()
            
            c = stdscr.getch()
            if c == ord('q'):
                break
            
            elif c == ord('n'):
                self.pad.job_scroll(1)
                self.display_pad()
                
            elif c == ord('p'):
                self.pad.job_scroll(-1)
                self.display_pad()
                
            elif c == ord('e'):
                self.expandall = not self.expandall
                if not self.expandall:
                    self.pad.set_job_scroll()
                self.display_pad()
                
            elif c == ord('w'):
                self.use_id = not self.use_id
                self.display_pad()

            elif c == ord('h'):
                self.show_complete = not self.show_complete
                self.display_pad()

            elif c == ord('j'):
                self.pad.single_scroll(1)
                self.display_pad()
            elif c == ord('k'):
                self.pad.single_scroll(-1)
                self.display_pad()
        
if len(sys.argv) > 1:
    main = Main_Program(sys.argv[1])
else:
    main = Main_Program()
    
wrapper(main.main)
    
    

