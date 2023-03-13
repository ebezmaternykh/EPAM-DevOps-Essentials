#! /bin/bash

#Prepare divided by ";" strings to avoid the problem with quoted commas
gawk 'BEGIN { FPAT = "([^,]*)|(\"[^\"]+\")" } { print $1";"$2";"$3";"$4";"$5";"$6 }' "$1" |
#Read the pipe output line by line
while IFS=";" read id loc_id name title email dep
	do
#Check if it's not the header
		if [ $id != "id" ]
		then
#Clear the temp variable
			unset name_new
#Separate name and surname
		for n in $name; do
#Check if the temp variable is empty
			if [ -z "$name_new" ]
			then
#Make the first name letter capital
				name_new="${n^}"
#Make the first part of template for email doubles search
				template="$( echo ${n} | grep -o "^." )" 
#Add to email the first name letter (lowercase)
				email_new="$( echo ${n,,} | grep -o "^." )"
			else
#The variable's not empty, so work with surname
#Add space and make the first letter capital
				name_new+=" ${n^}"
#The second part of template for email doubles search
				template+=".*\s${n}"
#Add the surname to email (lowercase)
				email_new+="${n,,}"
#Find doubles in names by the template
				dubl=$( grep -ci "$template" "$1" )
				if (( $dubl > 1 ))
				then
#Add location id to duplicated emails
					email_new+="$loc_id"
				fi
#Add the domain to email
				email_new+="@abc.com"
			fi
		done
#Add the new string to the new file
			echo "$id,$loc_id,$name_new,$title,$email_new,$dep" >> "$(dirname $1)/accounts_new.csv"
		else
#Create the new file with the coloumn names
			echo "$id,$loc_id,$name,$title,$email,$dep" > "$(dirname $1)/accounts_new.csv"
		fi
done
