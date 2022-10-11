
# Input bindings are passed in via param block. Name of bindings in function.json used as variables
param($Timer)

function PushToBlob($BlobParam,$pilot)
{
  Push-OutputBinding -Name $BlobParam -Value $pilot
}

function DefineBlobParam($CID)
{
  $BlobParam = "TestBlobDump"
  PushToBlob $BlobParam $Pilot
}

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

$rawvatsimdata = Invoke-WebRequest -Method GET -uri "https://data.vatsim.net/v3/vatsim-data.json" -UseBasicParsing
$rawpilotdata = (ConvertFrom-Json -InputObject $Rawvatsimdata).pilots

#Airforceproud95 1230578
#Hutchinson 1466155
#Bob 1617597
#Londoncontroller has conditional requirements, will be executed on a seperate if block
$scopedCids = @("1450744")

foreach($pilot in $rawpilotdata)
{ 
  if($pilot.cid -in $scopedCids)
  {
    DefineBlobParam $pilot.cid
  }
}