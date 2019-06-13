# box-of-pain-mongodb 
This repository is for using [Box of
Pain](https://techxplore.com/news/2019-05-pain-tracer-fault-injector.html) on a
Mongodb setup. It will run Box of Pain on a specified number of mongod
instances configured as a single replica set and run the
[YCSB](https://github.com/brianfrankcooper/YCSB) workload A test (50% reads,
50% writes). Box of Pain traces the execution of the system and its output is
sent to a file `pain.log` in the working directory. Each replica will be given
its own subdirectory of the working directory to store its information in, such
as the journal and its log.

PREREQUISITES: You must have Box of Pain installed. As of the time of writing, 
Box of Pain is not publicly available but should be "soon" according to its 
creators.

TO SETUP: Simply run `bash setup.bash` from within the home directory of this
repository.  If you do not have mongodb installed, the script will require root
privileges to install it.

TO USE: The main script is `run.bash`. Its command-line arguments are 
- the filepath of the Box of Pain executable
- the number of replicas to use
- which port the first replica will use
- the filepath of the YCSB directory.  

Following replicas will use the subsequent ports, so if the provided port is
11111, the other replicas will use ports 11112, 11113, and so on.  

EXAMPLE:
`bash run.bash ../box-of-pain/painbox 3 11220 ./ycsb-0.15.0/`

The results of a test (including all logs, generated files, etc.) can be cleared
out by calling `bash clean.bash`.
