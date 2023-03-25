#! usr/bin/bash

# this is a script to automate the updating of my validator nodes.  All paths are hard-coded...

txtred=$(tput setaf 1) # set a variable to create red text for output
txtbold=$(tput bold) # set a variable to create bold text for output
txtreset=$(tput sgr0) # set a varaiable to reset the font for output

# set up a function to write to an output log
logfile="/home/jamescbury/ETH_Validator_Update_Log.txt"
function output_log () {
	elapsed_time=$(($SECONDS - $start_time)) # calculate the elapsed time
	echo "$filename has been installed. Completed in ${elapsed_time} seconds" # let user know in the terminal that the install completed
	echo "["$(date)"] Installed:" $filename "Total time:" ${elapsed_time} "seconds" >> ${logfile} # append a transaction to the end of the log.  If the file does not exist create it.
	}

# determine if script is being run as root ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo "The script needs to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

# Choose which service you want to update
echo "Hello, you are about to update the services running to support the validator node."
echo "Select one option from below by entering 1,2,3"
echo "  1. Update Nethermind"
echo "  2. Update Lighthouse"
echo "  3. Update Mev-Boost"

read choice
start_time=$SECONDS #set the start time

case $choice in
	1) # Update Nethermind
		echo -e "\n${txtred}${txtbold}You are about to update Nethermind\n${txtreset}"
		echo -e "enter the path to the latest Nethermind release for Linux x64 from '\e]8;;https://github.com/NethermindEth/nethermind/releases/\e\\Nethermind Releases\e]8;;\e\\' below: " 
		read file_path

		cd ~
		filename=$(curl -L -O -w '%{filename_effective}' $file_path | awk {'print $1'})
		echo "$filename has been downloaded"
			#TODO add functionality to verify file hash for authenticity 
		unzip $filename -d nethermind # unzip the files
		systemctl stop nethermind # stop the service
		rm -r /usr/local/bin/nethermind # Remove the old files
		cp -a nethermind /usr/local/bin/nethermind # Copy the files
		systemctl start nethermind # Restart the service
		# cleanup
		rm $filename
		rm -r nethermind
		output_log #write to the output log
		;;
	2) # Update Lighthouse
		echo -e "\n${txtred}${txtbold}You are about to update Lighthouse\n${txtreset}"

		echo -e "Enter the path to the latest lighthouse release for Linux 64 (NOT THE PORTABLE ONE) from '\e]8;;https://github.com/sigp/lighthouse/releases\e\\Lighthouse releases\e]8;;\e\\' below: " 
		read file_path

		cd ~
		filename=$(curl -L -O -w '%{filename_effective}' $file_path | awk {'print $1'})
		echo "$filename has been downloaded"
			#TODO add functionality to verify file hash for authenticity 
		tar xvf $filename
		systemctl stop lighthousevalidator # stop the validator service
		systemctl stop lighthousebeacon # stop the beacon chain service
		cp lighthouse /usr/local/bin # copy the files to local bin
		systemctl start lighthousevalidator # restart the validator service
		systemctl start lighthousebeacon # restart the beacon chain service
		# cleanup
		rm lighthouse $filename # remove the downloaded files
		output_log #write to the output log
		;;
	3) # Update Mev-Boost
		echo -e "\n${txtred}${txtbold}You are about to update mev-boost\n${txtreset}"

		echo -e "Enter the path to the latest mevboost release for Linux amd64 from '\e]8;;https://github.com/flashbots/mev-boost/releases/\e\\mev-boost releases\e]8;;\e\\' below: " 
		read file_path

		cd ~
		filename=$(curl -L -O -w '%{filename_effective}' $file_path | awk {'print $1'})
		echo "$filename has been downloaded"
			#TODO add functionality to verify file hash for authenticity 
		tar xvf $filename
		systemctl stop mevboost # stop the service
		cp mev-boost /usr/local/bin # copy the files to local bin
		chown mevboost:mevboost /usr/local/bin/mev-boost # reset the ownership
		systemctl start mevboost # restart the service
		# cleanup
		rm mev-boost LICENSE README.md $filename # remove the downloaded files
		output_log #write to the output log
		;;
	*) # Invalid option selected
		echo "Invaild choice.  Please enter 1, 2, or 3."
		exit 1
		;;
esac
		
