# box-of-pain-mongodb
This repository is for using Box of Pain on a Mongodb setup.

TO SETUP:
Simply run `bash setup.bash` from within the home directory of this repository. 

TO USE:
The main script is `run.bash`. Its command-line arguments are the filepath of 
the Box of Pain executable, the number of replicas to use, and which port the
first replica will use. Following replicas will use the subsequent ports, so if
the provided port is 11111, the other replicas will use ports 11112, 11113, and
so on. 
EXAMPLE:
`bash run.bash ../box-of-pain/painbox 3 11220`

The results of a test can be cleared out by calling `bash clean.bash`.
