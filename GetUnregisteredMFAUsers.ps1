# Connect to Azure AD
Connect-MsolService

# Get a list of all users and their MFA status
$users = Get-MsolUser -All | Select-Object DisplayName, UserPrincipalName, @{
    Name = "MFA Status"
    Expression = {
        if ($_.StrongAuthenticationRequirements.State -ne $null) {
            $_.StrongAuthenticationRequirements.State
        } else {
            "Disabled"
        }
    }
}

$users
