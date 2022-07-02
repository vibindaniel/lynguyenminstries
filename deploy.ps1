$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
$currentPath = $(Get-Location).Path

Get-ChildItem
Get-Location

Trap
{
  Write-Error $_ -ErrorAction Continue
  exit 1
}

function CommandAliasFunction
{
  Write-Information ""
  Write-Information "$args"
  $cmd, $args = $args
  & "$cmd" $args
  if ($LASTEXITCODE)
  {
    throw "Exception Occured"
  }
  Write-Information ""
}

Set-Alias -Name ce -Value CommandAliasFunction -Scope script

[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($env:KUBECONFIG_BASE64)) `
| Out-File $currentPath/kubeconfig

$env:KUBECONFIG = "$currentPath/kubeconfig"

ce kubectl create namespace ${env:NAMESPACE} --dry-run=client -o yaml `
| kubectl apply -f -

ce kubectl label namespace ${env:NAMESPACE} goldilocks.fairwinds.com/enabled=true --overwrite=true

ce kubectl create secret docker-registry githubcreds `
  -n ${env:NAMESPACE} `
  --docker-server ${env:IMAGE_REPOSITORY} `
  --docker-username ${env:IMAGE_USER} `
  --docker-email ${env:IMAGE_EMAIL} `
  --docker-password=${env:IMAGE_SECRET} `
  --dry-run=client -o yaml | kubectl apply -f  -

ce helm dependency update ./charts/lynguyenminstries

ce helm template wordpress ./charts/lynguyenminstries `
  -n ${env:NAMESPACE} `
  --set "imagePullSecrets[0].name=githubcreds" `
  --set "image.tag=${env:GITHUB_SHA}" `
  --set "image.repository=${env:IMAGE_REPOSITORY}/${env:IMAGE_USER}/${env:IMAGE_NAME}" `
  --create-namespace `
  --debug

ce helm upgrade --install wordpress ./charts/lynguyenminstries --create-namespace `
  -n ${env:NAMESPACE} `
  --set "imagePullSecrets[0].name=githubcreds" `
  --set "image.tag=${env:GITHUB_SHA}" `
  --set "image.repository=${env:IMAGE_REPOSITORY}/${env:IMAGE_USER}/${env:IMAGE_NAME}" `
  --create-namespace `
  --wait --wait-for-jobs
