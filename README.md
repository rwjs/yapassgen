./yapassgen [OPTIONS]..

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
