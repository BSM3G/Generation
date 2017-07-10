import re
import curses
import time
from curses import wrapper



formating="{:>30.30}  | {:>11}  | {:>13}  | {:>11}  |"
display_option = "id"
other_option = "sample"
finished_jobs = {}
start_line = 2


def redo_spacing(file_complete, need_up):
    global start_line
    new_cur_line = -1
    space = 0

    new_need_up = []
    found = False
#    print file_complete
    for item in need_up:
        filename = item[0]
        line = int(item[1])
        print filename
        if filename == file_complete:
            new_need_up.append([filename, str(line)])
            space = -1*line
            found = True
            print "here"
            continue
        if found:
            if space < 0:
                space = line + space - 1
            new_need_up.append([filename, str(line - space)])
        else:
            new_need_up.append([filename, str(line)])
            

    return new_need_up



def get_job_dict(file_name):
    f = open(file_name, 'r')
    job = {}
    tmp = {}
    fill_dict = False
    job_num = ""
    
    for line in f:
        line = line.strip()
        m = re.search("Job ID : (\d+)", line)
        if m is not None:
            job_num = m.group(1)
            continue

        if line == ("-" * 80) and len(tmp) != 0:
        
            job[tmp["array_task_id"]] = tmp
            tmp = {}
            continue
        line_arr = line.split()
        if len(line_arr) != 3:
            continue
        tmp[line_arr[0]] = line_arr[2]
    job["1"]["job_num"] = job_num
    return job

def update_jobs(stdscr, need_up, option="none"):
    global display_option
    global other_option
    global finished_jobs

    if option == "switch":
        display_option, other_option = other_option, display_option
    for item in need_up:
        filename = item[0]
        first = int(item[1])

        if filename not in finished_jobs:
            print "hoojhadf" 
            job = get_job_dict(filename)
            pass_all = True
            max_time = 0
            for item in job.itervalues():

                if item["job_state"] != "COMPLETED": 
                    pass_all = False
                    break
                if max_time < item["run_time"]:
                    max_time = item["run_time"]
            if pass_all:

                finished_jobs[filename] = [job["1"]["job_num"], job["1"]["array_task_id"], str(max_time)]

        if filename in finished_jobs:

            tmp_array = finished_jobs[filename]
            job_num = tmp_array[0] 
            array_num = tmp_array[1]
            run_time = tmp_array[2]

            if display_option == "id":
                pass
            elif display_option == "sample":
                job_num = filename
            
            write_str = formating.format(job_num, array_num, "COMPLETED", run_time)
            stdscr.addstr(first, 0, write_str, curses.color_pair(3) | curses.A_BOLD)
            continue

                

        for i in xrange(len(job)):
            tmp_array = job[str(i+1)]
            color = curses.color_pair(1) #green
            if tmp_array["job_state"] == "COMPLETED":
                color = curses.color_pair(3)
            job_num = ""
            if "job_num" in tmp_array: 
                if display_option == "id":
                    job_num = tmp_array["job_num"]
                elif display_option == "sample":
                    job_num = filename
            write_str = formating.format(job_num, tmp_array["array_task_id"], tmp_array["job_state"], tmp_array["run_time"])
            stdscr.addstr(i+first, 0, write_str, color | curses.A_BOLD)




def wrapping(stdscr):
    stdscr.clear()
    curses.start_color()
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_BLACK)

    sample_list = "SAMPLES_LIST.txt"

    need_up =[]
    global start_line
    cur_line = start_line
    f = open(sample_list)
    for filename in f:
        filename = filename.strip()

        if filename.strip() == "" or filename[0] == '#' or filename[:2] == '//':
            continue
        print filename
        filename += "_log.txt"
        tot_job = len(get_job_dict(filename))
        need_up.append([filename, str(cur_line), str(cur_line+tot_job)])
        cur_line += tot_job
                        
    time.sleep(5)
    title = formating.format("Job ID", "Array ID", "State", "Run Time")
    stdscr.addstr(0,0, title, curses.color_pair(4))
    stdscr.addstr(1,0, "-"*(80), curses.color_pair(4))
    options = "    q - quit    |    r - refresh    |    w - switch ID with Sample"
    stdscr.addstr(cur_line+2, 0, options, curses.color_pair(4))
    update_jobs(stdscr, need_up)
    stdscr.refresh()
    global finished_jobs

    while True:
        c = stdscr.getch()
        if c == ord('q'):
            break
        elif c == ord('r'):
            for filenames in finished_jobs:

                need_up = redo_spacing(filename, need_up)
            update_jobs(stdscr, need_up)
            stdscr.refresh()
        elif c == ord('w'):
            update_jobs(stdscr, need_up, "switch")
            stdscr.refresh()




wrapper(wrapping)




