[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "ID of the Docker Container")]
    [String]
    $ContainerId,

    [Parameter(Mandatory = $true, HelpMessage = "Name of the public key file to transmit")]
    [String]
    [ValidateScript({Test-Path -Path ~/.ssh/$_}, ErrorMessage = "File does not exist!")]
    $KeyFile
)


$pub_key = Get-Content ~/.ssh/$KeyFile

docker exec -it $ContainerId powershell -Command Out-File C:\ProgramData\ssh\administrators_authorized_keys -InputObject "'${pub_key}'" -Encoding UTF8 -Append