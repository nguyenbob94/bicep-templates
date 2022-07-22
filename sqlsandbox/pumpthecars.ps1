param(
  [switch]$AddCars,
  [switch]$RemoveAddedCars
)
# No need for this section if http request is done through SQL stored proc
$LogicAppURI = "https://"

# Db variables. Change if desired
$serverName = "sql-def2\CARS"
$databaseName = "cars"
$tableName = "cars"

# Data input variables. Change if desired


#$defaultID = Get-Random -Maximum 100 # UIDS are randomly generated per db configuration
$arrayOfMakes = @("Toyota","BMW","Powell Motors")
$arrayOfModels = @("AE86","M1lkers Car","Persephone")
$arrayLuxary = @(0,1,0)

# Connection to SQL variables
$Connection = New-Object System.Data.SqlClient.SqlConnection
$Connection.ConnectionString = "server='$serverName';database='$databaseName';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SqlClient.SqlCommand
$Command.Connection = $Connection

# Iterator  
$i = 0

if($AddCars -eq $True)
{
  do
  {
    $MakeResult = $arrayOfMakes[$i]
    $ModelResult = $arrayOfModels[$i]
    $LuxaryResult = $arrayLuxary[$i]

    # SQL Query goes here
    # Change values and column names according to SQL Table
    $insertquery="
    INSERT INTO $tableName
      ([make],[model],[luxury])
    VALUES
      ('$MakeResult','$ModelResult','$LuxaryResult')"

    # Command to add query into SQL
    $Command.CommandText = $insertquery
    $Command.ExecuteNonQuery()

    sleep 02
     
    # No need for this section if http request is done through SQL stored proc
    # Obtain last id of insert for http invoke
    #$UID = (Read-SqlTableData `
    #-ServerInstance "sql-def2\CARS" `
    #-DatabaseName "cars" `
    #-SchemaName "dbo" `
    #-TableName "cars" | Select -Last 1 id).id

    #$StringTojson = ConvertTo-Json @{id = "$UID"}
    #Invoke-WebRequest -uri $uri -method POST -body $StringTojson -ContentType "application/json"

    $i++
   
  } Until ($i -gt 2)
      
} 

# Edit to your hearts content but be careful of deleting tables you're not suppose to
if($RemoveAddedCars -eq $True)
{
  do
  {
    #Add more if you wish
    $ModelResult = $arrayOfModels[$i]

    # SQL Query goes here
    # Change values and column names according to SQL Table
    $insertquery="
    DELETE FROM $tableName WHERE model='$ModelResult'
    DELETE FROM staging WHERE model='$ModelResult'"

    # Command to add query into SQL
    $Command.CommandText = $insertquery
    $Command.ExecuteNonQuery()

    $i++

  } Until ($i -gt 2)

}

$Connection.Close();
