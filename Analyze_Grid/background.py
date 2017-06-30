import luigi
import luigi.cmdline as lc


i = 10

lc.luigid(["--background", "--pidfile", "PID", "--logdir", "LOG"])
