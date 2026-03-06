param(
    [Parameter(Mandatory=$true)]
    [string]$BearerToken
)

$env:OCTOPUS_TEMPK8S_GRPC_HOSTNAME = "mattc.octopus.app:8443"
$env:OCTOPUS_TEMPK8S_HOSTNAME = "mattc.octopus.app"
$env:OCTOPUS_TEMPK8S_POLLING_HOSTNAME = "polling.mattc.octopus.app"
$env:OCTOPUS_TEMPK8S_SPACE = "Easy Mode"
$env:OCTOPUS_TEMPK8S_SPACE_ID = "Spaces-4588"
$env:OCTOPUS_TEMPK8S_BEARER_TOKEN = $BearerToken

vagrant up