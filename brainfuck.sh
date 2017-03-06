#!/usr/bin/env bash


# In classic brainfuck mod 256
MAX_CODE=255
MAX_DATA_POS=30000
PROG=""

# DATA stores ASCII codes of symbols
declare -a DATA || echo "It sucks to have the last version of bash, isn\`t it?"

DATA_POS=0


EchoDataRaw() {
	echo -n ${DATA[@]}
}

# That may be helpfull for debug purpose.
# Not currently used in the code
EchoDataChar() {
	for i in $(EchoDataRaw)
	do
		Chr $i
	done
}

# Symbol by code
Chr() {
	printf "\\$(printf %o "$1")"
}

# Code by symbol
Ord() {
	echo -n "$1" | od -An -t uC | tr -d " "
}

# To avoid initialising of MAX_DATA_POS elements "" is equal to 0
GetCurCode() {
	local code=${DATA[$DATA_POS]}
	if [[ $code == "" ]]
	then
		echo -n "0"
	else
		echo -n "$code"
	fi
}

# Here are some problems with \n if we use echo -n
GetCurSym() {
	# 10 is ascii code of \n
	if [[ $(GetCurCode) == 10 ]]
	then
		echo
	else	
		echo -n "$(Chr $(GetCurCode))"
	fi
}

# Not the best name, but I am too lazy to rename
# It puts given ASCII code to DATA
ChangeCode() {
	local newSymCode="$1"
	local pos="$2"
	DATA[$pos]=$newSymCode
}


Plus() {
	if [[ $(GetCurCode) == $MAX_CODE ]] # mod MAX_CODE
	then
		ChangeCode 0 $DATA_POS
	else
		# It works ok with uninitialized vars
		# becous GetCurCode returns 0 on ""
		local curSymCode=$(GetCurCode)
		local curSymCode=$(($curSymCode+1))
		ChangeCode $curSymCode $DATA_POS
	fi
}

Minus() {
	if [[ $(GetCurCode) == 0 ]] # mod MAX_CODE
	then
		ChangeCode $MAX_CODE $DATA_POS
	else
		local curSymCode=$(GetCurCode)
		local curSymCode=$(($curSymCode-1))
		ChangeCode $curSymCode $DATA_POS
	fi
}

MoveRight() {
	DATA_POS=$(($DATA_POS+1))
	if [[ ($MAX_DATA_POS != 0) &&  ($DATA_POS == $(($MAX_DATA_POS + 1))) ]]
	then
		echo "DEBUGGGGGG IT!!!!"
		echo "U moved too right, lol"
		exit 1
	fi
}

MoveLeft() {
	DATA_POS=$(($DATA_POS-1))
	if [[ $DATA_POS < 0 ]]
	then
		echo "DEBUGGGGGG IT!!!!"
		echo "U moved too left, lol"
		exit 1
	fi
}

Worker() {
	local curProgPos=$1
	while [[ ${PROG:curProgPos} != "" ]]
	do
		case ${PROG:curProgPos:1} in
			"+")
				Plus
			;;
			"-")
				Minus
			;;
			">")
				MoveRight
			;;
			"<")
				MoveLeft
			;;
			"[")
				while [[ $(GetCurCode) != 0 ]]
				do
					Worker $(($curProgPos+1))
				done
				
				# for nested brackets []
				local numOfBrackets=1
				while [[ $numOfBrackets != 0 ]]
				do
					let curProgPos+=1
					case ${PROG:curProgPos:1} in
						"[")
							let numOfBrackets+=1
						;;
						"]")
							let numOfBrackets-=1
						;;
					esac
				done
			;;
			"]")
				return 0
			;;
			".")
				GetCurSym
			;;
			",")
				# If no vars specified read puts intput in REPLY
				read -s -n 1 -r
				ChangeCode $(Ord "$REPLY") $DATA_POS
			;;
		esac
		local curProgPos=$(($curProgPos+1))
	done
}




while getopts ":hp:m:l:-" arg; do
  case $arg in
    h|-)
      echo "Script takes args only in nonGNU style."
      echo "-h - this help msg"
      echo "-p STRING - ur programm. If not specified or - reads from stdin"
      echo "-m INT - max value of cell. Default is 255. (mod 256)"
      echo "-l INT - number of cells. Default is 30 000. Enter 0 to have no limit"
      exit 0
      ;;
    p)
    	PROG="$OPTARG"
    ;;
    m)
    	# Here will be mistake if user give bad input with spaces, but
    	# there is no way. Spaces in INT is something
    	# strange so looks like it`s the best format
    	MAX_CODE=$OPTARG 2> /dev/null
    ;;
    l)
    	# Same as higher
    	MAX_DATA_POS=$OPTARG 2> /dev/null
    ;;
    \?)
      echo "Invalid option: -$OPTARG Lurk -h"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument. Lurk -h"
      exit 1
      ;;
  esac
done

if [[ ($PROG == "") || ($PROG == "-") ]]
then
	read PROG
fi

Worker 0





