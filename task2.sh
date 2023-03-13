#! /bin/bash

#Define the output file
outfile="$(dirname $1)/output.json"
#Read the input file string by string
while read -r string || [ -n "$string" ]
	do
#Define the regular expression for the test name
		headregexp="^\[[[:space:]]+(.*)[[:space:]]+\],.+$"
#Separate the testname
		[[ $string =~ $headregexp ]] && testname=${BASH_REMATCH[1]}
#Define the regexp for every test
		testsregexp="^(.+k)[[:space:]]+([[:digit:]]+)[[:space:]]+(.+\)),[[:space:]]+([[:digit:]]+ms)$"
#Separate the parameters of each test
		[[ $string =~ $testsregexp ]] && num=${BASH_REMATCH[2]} && result[num]=${BASH_REMATCH[1]} && name[num]=${BASH_REMATCH[3]} && dur[num]=${BASH_REMATCH[4]}
#Regexp for the test result
		footerregexp="^([[:digit:]]+)[[:space:]]+\(of[[:space:]]+([[:digit:]]+)\).+,[[:space:]]+([[:digit:]]+)[[:space:]]+.+[[:space:]]+as[[:space:]]+([[:digit:]]+\.*[[:digit:]]*)%.+[[:space:]]+([[:digit:]]+ms)$"
#Separate test result values
		[[ $string =~ $footerregexp ]] && success=${BASH_REMATCH[1]} && total=${BASH_REMATCH[2]} && failed=${BASH_REMATCH[3]} && rating=${BASH_REMATCH[4]} && duration=${BASH_REMATCH[5]}
#Specify the input file
	done < $1
#Generate the json and write it to the output file
echo '{
 "testName": "'$testname'",
 "tests": [' > $outfile
	for i in ${!result[@]}; do
		echo '  {
   "name": "'${name[i]}'",
   "status": '$( if [ "${result[i]}" = "ok" ]; then echo "true"; else echo "false"; fi; )',
   "duration": "'${dur[i]}'"' >> $outfile
		if (( $i < ${#result[@]} ))
		then echo  '  },' >> $outfile
		else echo '  }' >> $outfile
		fi
	done
echo ' ],
  "summary": {
   "success": '$success',
   "failed": '$failed',
   "rating": '$rating',
   "duration": "'$duration'"
 }
}' >> $outfile
