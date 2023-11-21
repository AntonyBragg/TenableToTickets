using module "S:\Modules\Write-Log\Class\Write-Log\Write-Log-Class.psm1" # For log writing
<#
.SYNOPSIS
    Creates Helpdesk tickets from a Tenable Export

.DESCRIPTION
    Using a Tenable JSON export this script will create tickets with all of the information from the export as well as attempting to get 
    the owner of the device.

.NOTES
    Author           : Antony Bragg
    Creation Date    : 28/09/2023
    Script Version   : 1.0.0
    Template Version : 1.0.0
    GitHub Repo      : https://github.com/Gen2Training/TenableToTickets
    ReadMe           : https://github.com/Gen2Training/TenableToTickets/blob/main/README.md

<#-----[ Latest Patch Notes ]-----#

Version 1.0.0
    * Initial Creation

#>

#-----[ Requirements ]-----#

#Requires -Version 7.0

#-----[ Module Setup ]-----#

# Configuring Log
try { 
    $Log = [WriteLog]::New("$psscriptroot\Files\Logs\Log.log")
} catch {
    Write-Error "Something went wrong setting up log"
    exit 1
}

#-----[ Configuration ]-----#

try {
    $JsonFilePath = (Get-ChildItem "$psscriptroot\Files\*.json").FullName
} catch {
    $Log.AddError("Issue with the JSON file")
    exit 1
}

$url = "https://helpdesk.gen2training.co.uk/api/v3/requests"
$ApiKey = @{"authtoken" = "FE8E8E07-8DC7-475E-842A-50416660BD35"}

#-----[ Classes ]-----#

# No Classes

#-----[ Functions ]-----#

# No Functions

#-----[ Execution ]-----#

$Log.AddInfo("Script Executed")

try {
    $jsonContent = Get-Content -Raw -Path $JsonFilePath
} catch {
    $Log.AddError("Issue getting JSON file Content from $JsonFIlePath")
    exit 1
}

$objects = $jsonContent | ConvertFrom-Json
$aggregated = @{}

foreach ($object in $objects) {
    $name = $object.asset.name
    if ($aggregated.ContainsKey($name)) {
        $aggregated[$name].definitions += $object.definition
    } else {
        $aggregated[$name] = @{
            name = $name
            definitions = @($object.definition)
        }
    }
}

foreach ($obj in $aggregated.Values) {
    $body = "<h2>Tenable Issues</h2><hr>"

    foreach ($definition in $obj.definitions) {
        $body += "<p><b>Tenable Description</b></p><p>$($definition.description)</p>"
        $body += "<p><b>Tenable Output</b></p><p>$($definition.output)</p>"
        $body += "<p><b>Solution</b></p><p>$($definition.solution)</p>"
        $body += "<hr>"
    }

    try {
        $device = Get-ADComputer $obj.name -properties description
        if(($device.DistinguishedName -like "*Client Computers*") -or ($device.DistinguishedName -like "*Domain Controllers*")) {
            $user = "Server"
        } elseif($obj.name -like "GEN*") {
            $user = ($device.description).Split(",")[0]
        } else {
            $user = "Student"
        }
    } catch {
        $user = "Failed to get Device User"
    }

    $subject = "Tenable - $(($obj.name).ToUpper()) - $($user)"

    $message = @{
        request = @{
            subject = $subject
            description = $body
            requester =  @{
                id = "16502"
                name = "IT Support"
            }
            status = @{
                name = "Open"
            }
        }
    }
    $Log.AddInfo("Attempting to raise $($message.count) ticket(s)")
    $BodyJsonSend = $message | ConvertTo-Json -Depth 10
    $data = @{ 'input_data' = $BodyJsonSend }
    Invoke-RestMethod -Uri $url -Method post -Body $data -Headers $ApiKey -ContentType "application/x-www-form-urlencoded"
}