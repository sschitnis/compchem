#!/bin/bash

# This script takes a *.com file and uses information in it together with some commad line input (days/hours) via positional parameters to create a new *.sh file and then submits it. In order to do so, the script creates a "blank.sh" file using the requisite lines via the "cat" command. It then substitutes the contents of this file using "sed" and saves it with the same name as the initial * file.

# HOW TO USE THIS SCRIPT: Put this script in the same folder as the *.com, then run "submit file dd hh" where file = name of the .com file (without .com extension), dd = number of days, and hh = number of hours. 

# Create a blank.sh file that has required info.
cat > blank.sh << EOL
#!/bin/bash
#SBATCH --mem=diskMB            # memory amount, roughly 2 times %mem
#SBATCH --time=dd-hh:00        # time (DD-HH:MM)
#SBATCH --output=file.log  # output file
#SBATCH --cpus-per-task=nproc      # No. of cpus as defined by %nprocs
#SBATCH --account=def-chitnis  #

module load gaussian/g16.a03
g16 < file.com > file.log   # direct g16 command
EOL
###

# finds the %mem value from the .com file:
while IFS= read -r line; do
	MEMNUMBER=$(grep mem | sed 's/[^0-9]*//g')
done < $1.com
MEM=$(($MEMNUMBER * 2000))    # multiplies the %mem by 2000 to get value in MB
###

# finds the nproc value from the .com file:
while IFS= read -r line; do
	PROCNUMBER=$(grep nprocshared | sed 's/[^0-9]*//g')
done < $1.com
###

# replaces the word "disk" in blank.sh by $MEM string as evaluated above, replaces the word "dd" in blank.sh by the 2nd positional parameter, the word "hh" by the 3rd position parameter, and the word "file" (globally) by the 1st position paramter (name of file to save as):

sed -e 's/disk/'$MEM'/' -e 's/dd/'$2'/' -e 's/hh/'$3'/' -e 's/nproc/'$PROCNUMBER'/' -e 's/file/'$1'/g' blank.sh > $1.sh
###

# submits the file
sbatch $1.sh
###
