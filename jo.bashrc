####################################################################
# Jump Off aka jo - a very simple jump to directory script, 
#
# SETUP: Add this to your .bashrc,
#      source ~/.bashrc
#      jo -a foo path/to/foo
#      jo -a bar path/to/bar/dir
#      #Files are stored in ~/jo/ directory#
#
# USAGE: in bash, type jo foo, to cd to the directory contained in file ~/jo/foo
# @author relipse, major help from freenode #bash
# @license Public Domain or MIT, whichever preferred by user
# @version 1.1.0
####################################################################
function jo() { 
	# Reset all variables that might be set
	local verbose=0
	local list=0
	local add=0
	local adddir=0

	if (( $# == 0 )); then
	    echo "Try jo --help for more, but here are the existing jos:"
		ls ~/jo
	    return 0;
	fi


	while :
	do
	    case $1 in
	        -h | --help | -\?)
	            #  Call your Help() or usage() function here.
	            echo "Usage: jo <foo>, where <foo> is a file in ~/jo/ containing the full directory path."
	            echo "Jo Command line arguments:"
	            echo "    <foo> - cd to dir stored in contents of file ~/jo/<foo> (normal usage) "
	            echo "    --list -l             -  show jump files, (same as 'ls ~/jo') "
	            echo "    --add  -a <sn> <path> -  add/replace <sn> shortname to ~/jo with jump path <path>"
	            return 0      # This is not an error, User asked help. Don't do "exit 1"
	            ;;
	        -l | --list)
				list=$((list+1))
				shift
				;;
    		 -a | --add)
	            add=$2     # You might want to check if you really got FILE
	            adddir=$3
	            if [[ -d $adddir ]]; then
	            	echo "Warning: directory $adddir does not exist."
	            fi
	            shift 3
	            ;;
        	--add=*)
	            add=${1#*=}        # Delete everything up till "="
	            adddir=$2
	            if [[ -d $adddir ]]; then
	            	echo "Warning: directory $adddir does not exist."
	            fi
	            shift 2
            ;;
	        -v | --verbose)
	            # Each instance of -v adds 1 to verbosity
	            verbose=$((verbose+1))
	            shift
	            ;;
	        --) # End of all options
	            shift
	            break
	            ;;
	        -*)
	            echo "WARN: Unknown option (ignored): $1" >&2
	            shift
	            ;;
	        *)  # no more options. Stop while loop
	            break
	            ;;
	    esac
	done

    if  [[ $add != 0 ]]; then
        echo "$adddir" > ~/jo/"$add"
        if [ -f ~/jo/"$add" ]; then
        	echo $add added, try jo $add
        else
        	echo problem adding $add
        fi

        return 0;
    fi

	if (( list > 0 )); then
	    echo "Listing jos:"
		ls ~/jo
		return 0
	fi

	#check if jump file exists in ~/jo/ directory
	local file=$HOME/jo/"$1"
	if [ -f $file ]; then
		local fullpath=$(cat $file)
    else
    	echo Error: "'$1'" does not exist. Try this to add it:
    	echo jo --add $1 path/to/dir

    	#echo "$file does not exist. Use jo --add $file to add it."
    	return 1
    fi 


	if [ -d $fullpath ]
	then
		cd $fullpath
		pwd
	else
		echo $file exist, but 
		echo $fullpath does not exist

		#echo "To add/replace a jo jump file, type either: "
		#echo "jo --add <foo> <long-path-to-dir>"
		#echo "echo '<long-path-to-dir>' > ~/jo/<foo> "
	fi
}
#####
