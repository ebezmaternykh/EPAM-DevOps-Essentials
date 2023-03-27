#Get the input file as an argument
param($InputFile)
#Check if the input file was passed without path
if ( $InputFile -notmatch '.*\\.*' )
    { 
        $InputFile = ".\"+$InputFile
    }
#Define the output file
$OutputFile = (Split-Path $InputFile)+"\accounts_new.csv"
#Import the file to an array
$Accounts=Import-CSV -path $InputFile
#Read the pipe output line by line
$Accounts | ForEach-Object {
        #Make the first name and surname letters capital
        $_.Name=(Get-Culture).TextInfo.ToTitleCase($_.Name)
        #Use regexp to create an email mask
        $_.Name -match '^(?<firstlet>.).*\s(?<surname>.+)$' | Out-Null
        #Find doubles in names by the template
        if ( ($Accounts | Select-String -Pattern "name=$([regex]::escape($Matches.firstlet)).*$([regex]::escape($Matches.surname))").count -gt 1)
        #If there are duplicates, add the location id to the email address
        {
            $_.Email = $($Matches.firstlet+$Matches.surname+$_.Location_id+"@abc.com").ToLower()
        }
        #Otherwise, just the name by mask and the domain
        else 
        {
            $_.Email = $($Matches.firstlet+$Matches.surname+"@abc.com").ToLower() 
        }
    }
#Convert the edited array to the csv    
$Accounts | ConvertTo-Csv -NoTypeInformation | Out-File $OutputFile
