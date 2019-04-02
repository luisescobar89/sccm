Param([string]$device)

# Import SCCM module
Import-Module "$executingScriptDirectory\SCCM" -DisableNameChecking

# Copy the environment variables to their parameters
if (test-path env:\SNC_device) {
  $device     = $env:SNC_device
}

SNCLog-ParameterInfo @("Running InvokeClientNotificationMachinePolicy", $device)

function Invoke-ClientNotificationMachinePolicy() {
   Import-Module -Name "$(split-path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1"
   Set-Location -path "$(Get-PSDrive -PSProvider CMSite):\"

   $device = $args[0];

   $id = (Get-CMDevice -Name $device).ResourceID
   Invoke-CMClientNotification -ResourceID $id -ActionType ClientNotificationRequestMachinePolicyNow
}

$session = Create-PSSession -sccmServerName $computer -credential $cred
try {
    SNCLog-DebugInfo "`tInvoking Invoke-Command -ScriptBlock `$'{function:Invoke-ClientNotificationMachinePolicy}' -ArgumentList $device"
    Invoke-Command -Session $session -ScriptBlock ${function:Invoke-ClientNotificationMachinePolicy} -ArgumentList $device
} finally {
    Remove-PSSession -session $session
}