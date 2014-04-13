#!/bin/bash

MODE=chars
CLASS=''
WORDSOURCE='/usr/share/dict/british'
RANDSOURCE='/dev/urandom'
SAFETY_MULTIPLIER=10

################################## Functions #################################

randword() 
{
	dd if="$WORDSOURCE" status=none skip=$(echo $[ $RANDOM % $(du -L "$WORDSOURCE" | cut -f 1) ]) | awk 'getline {printf $0 ; exit}' | tr -d '\n'
}

randchar()
{
	tr -cd "${CLASS}" < "$RANDSOURCE" | head -c $LEN
}
main()
{
	if [[ -z "${LEN}" ]]
	then
		[[ -n "${MINLEN}" ]] || { echo 'No static length or minimum length specified!' ; exit 1 ; }
		[[ -n "${MAXLEN}" ]] || { echo 'No static length or minimum length specified!' ; exit 1 ; }
		LEN=$[ ${RANDOM} % $[ ${MAXLEN} - ${MINLEN} + 1 ] + ${MINLEN} ]
	fi
	[[ "${LEN}" =~ ^[0-9]+$ ]] || { echo "LEN must be an integer! (LEN=${LEN})" >&2 ; exit 1; }
	[[ "${LEN}" -ge 1 ]] || { echo "LEN less than 1? (LEN=${LEN})" ; exit 1 ; }

	case "$MODE" in
		words)
			[[ -e "${WORDSOURCE}" ]] || { echo "WORDSOURCE file not found? (WORDSOURCE=${WORDSOURCE})" >&2 ; exit 1 ; }

			NUM_ITER=0
			NUM_ITER_SUCC=0
			SAFETY=$[ $LEN * $SAFETY_MULTIPLIER ]
			while [[ $j -lt "${LEN}" ]]
			do
				let NUM_ITER+=1
				randword | tr -cd "${CLASS}" | sed 's/./&-/g' | grep -z . && let NUM_ITER_SUCC+=1
				[[ "${NUM_ITER_SUCC}" -ge "${LEN}" ]] && break
				if [[ "${NUM_ITER}" -ge "${SAFETY}" ]]
				then
					echo -e "Warning: Infinite Loop safety hit (are your filter/s too strict for your dictionary?" >&2
					exit 1
				fi
			done
			;;
		chars) 
			[[ -e "${RANDSOURCE}" ]] || { echo "RANDSOURCE file not found? (RANDSOURCE=${RANDSOURCE})" >&2 ; exit 1 ; }
			[[ -n "${CLASS}" ]] || CLASS='[:print:]' #{ echo 'No filters specified?' >&2 ; exit 1 ; }
			randchar
			;;
	esac
	echo
	exit 0
}

#################################### Help ####################################

HELP='./yapassgen [OPTIONS]..

Y(et) A(nother) Pass(word) Gen(erator).sh

Options:

    Misc:
	-h|-?|--help		Display this help and exit.

    Filters:
	-b|--blank		Include blank characters in the password
	-g|--graph		Include all printable characters (not including space) in the passwords
	-l|--lower		Include lowercase characters in the password
	-n|--digit		Include digits in the password
	-o|--cntrl|--control	Include control characters in the password
	-p|--punct		Include punctuation in the password
	-r|--print		Include all printable characters in the password
	-s|--space		Include spaces in the password
	-u|--upper		Include uppercase characters in the password
	-x|--hex|--hexadecimal	Include hexadecimal characters in the password

    Modes:
	-c|--char|--characters	Generate a password made of characters ("Character Mode")
	-w|--word|--xkcd	Generate a password made of words ("Word Mode")

    Length:
	-m|--minlen=(?)		Set the minimum length for the password
	-M|--maxlen=(?)		Set the maximum length for the password
	-L|--len|--length=(?)	Set the fixed length for the password (overrides --minlen and --maxlen)

    Data:
	--randsource=(?)	Set the random character generator to use in Character Mode
	--wordsource|--dict=(?)	Set the dictionary to use in Word Mode (expects one word per line).

Notes:
 - Filters are inclusive - specifying multiple filters will include anything from that set.
 - Long options are generally case and plural insensitive.
 - Both equal-separated and space-separated options values are accepted.
'

################################ Parse Options ###############################

shopt -s extglob

while [[ -n "$@" ]]
do
	case $1 in
		-[hH]|--[hH][eE][lL][pP]) echo "$HELP" && exit ;;

			# CLASSES
		-b|--[bB][lL][aA][nN][kK]?([sS])) CLASS="${CLASS}[:blank:]" ;;
		-g|--[gG][rR][aA][pP][hH]?([sS])) CLASS="${CLASS}[:graph:]" ;;
		-l|--[lL][oO][wW][eE][rE]?([sS])) CLASS="${CLASS}[:lower:]" ;;
		-n|--[dD][iI][gG][iI][tT]?([sS])|--[nN][uU][mM][bB][eE][rR][sS]?) CLASS="${CLASS}[:digit:]" ;;
		-o|--[cC][nN][tT][rR][lL]?([sS])|--[cC][oO][nN][tT][rR][oO][lL]?([sS])) CLASS="${CLASS}[:cntrl:]" ;;
		-p|--[pP][uU][nN][cC][tT]?([sS])) CLASS="${CLASS}[:punct:]" ;;
		-r|--[pP][rR][iI][nN][tT]?([sS])) CLASS="${CLASS}[:print:]" ;;
		-s|--[sS][pP][aA][cC][eE]?([sS])|--[wW][hH][iI][tT][eE]?([sS])|--[wW][hH][iI][tT][eE]?(-)[sS][pP][aA][cC][eE]?([sS])) CLASS="${CLASS}[:space:]" ;;
		-u|--[uU][pP][pP][eE][rR]?([sS])) CLASS="${CLASS}[:upper:]" ;;
		-x|--[hH][eE][xX]?[sS]|--[hH][eE][xX][aA][dD][eE][cC][iI][mM][aA][lL]?([sS])) CLASS="[:xdigit:]" ;;

		-c|--[cC][hH][aA][rR]?([sS])|--[cC][hH][aA][rR][aA][cC][tT][eE][rR]?([sS])) MODE=chars ;;
		-w|--[wW][oO][rR][dD]?([sS])|--[xX][kK][cC][dD]) MODE=words ;;
		
		-m?(=)*|--[mM][iI][nN]?(-)[lL][eE][nN]?(=)*)
			MINLEN=$(echo -n "$1" | sed -n 's/^--\?[^=]*=//p')
			[[ -z "${MINLEN}" ]] && { shift ; MINLEN="$1" ; }
			[[ "${MINLEN}" =~ ^[0-9]+$ ]] || { echo "MINLEN must be an integer! (MINLEN=${MINLEN})" >&2 ; exit 1; }
			[[ "${MINLEN}" -ge 1 ]] || { echo "MINLEN less than 1? (MINLEN=${MINLEN})" ; exit 1 ; }
		;;
		-M?(=)*|--[mM][aA][xX]?(-)[lL][eE][nN]?(=)*)
			MAXLEN=$(echo -n "$1" | sed -n 's/^--\?[^=]*=//p')
			[[ -z "${MAXLEN}" ]] && { shift ; MAXLEN="$1" ; }
			[[ "${MAXLEN}" =~ ^[0-9]+$ ]] || { echo "MAXLEN must be an integer! (MAXLEN=${MAXLEN})" >&2 ; exit 1; }
			[[ "${MAXLEN}" -ge 1 ]] || { echo "MAXLEN less than 1? (MAXLEN=${MAXLEN})" ; exit 1 ; }
		;;
		-L?(=)*|--[lL][eE][nN]?(=)*|--[lL][eE][nN][gG][tT][hH]?(=)*)
			LEN=$(echo -n "$1" | sed -n 's/^--\?[^=]*=//p')
			[[ -z "${LEN}" ]] && { shift ; LEN="$1" ; }
			[[ "${LEN}" =~ ^[0-9]+$ ]] || { echo "LEN must be an integer! (LEN=${LEN})" >&2 ; exit 1; }
			[[ "${LEN}" -ge 1 ]] || { echo "LEN less than 1? (LEN=${LEN})" ; exit 1 ; }
		;;

		--[wW][oO][rR][dD]?(-)[sS][oO][uU][rR][cC][eE]?(=)*|--[dD][iI][cC][tT]?(=)*|--[dD][iI][cC][tT][iI][oO][nN][aA][rR][yY]?(=)*)
			WORDSOURCE=$(echo -n "$1" | sed -n 's/^--\?[^=]*=//p')
			[[ -z "$WORDSOURCE" ]] && { shift ; WORDSOURCE="$1" ; }
			[[ -e "$WORDSOURCE" ]] || { echo "WORDSOURCE file '$WORDSOURCE' not found?" >&2 ; exit 1 ; }
		;;

		--[rR][aA][nN][dD]?(-)[sS][oO][uU][rR][cC][eE]?(=)*)
			RANDSOURCE=$(echo -n "$1" | sed -n 's/^--\?[^=]*=//p')
			[[ -z "${RANDSOURCE}" ]] && { shift ; RANDSOURCE="$1" ; }
			[[ -e "${RANDSOURCE}" ]] || { echo "RANDSOURCE file '${RANDSOURCE}' not found?" >&2 ; exit 1 ; }
		;;

	esac
	shift
done

############################### Error Checking ###############################

[[ -n "${MINLEN}" ]] && [[ -n "${MAXLEN}" ]] && [[ "${MAXLEN}" -le "${MINLEN}" ]] && { echo "MAXLEN is less-than-or-equal-to MINLEN? (MINLEN=${MINLEN}, MAXLEN=${MAXLEN})" >&2 ; exit ; }

##################################### Run ####################################

main
