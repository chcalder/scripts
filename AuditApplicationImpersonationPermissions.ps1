
# This script retrieves all users with the ApplicationImpersonation role assigned, regardless of any special role assignments that have been set up

<# 

Audit identities that hold ApplicationImpersonation privileges in Exchange Online. ApplicationImpersonation allows a caller, such as a service principal, 
to impersonate a user and perform the same operations that the user themselves could perform. Impersonation privileges like this can be configured 
for services that interact with a mailbox on a user’s behalf, such as video conferencing or CRM systems. If misconfigured, or not scoped appropriately, 
these identities can have broad access to all mailboxes in an environment. Permissions can be reviewed in the Exchange Online Admin Center, or via PowerShell: 

#>

<#  
    Note: To run the Get-ManagementRoleAssignment cmdlet in Exchange Online, you need to have the 
    Role Management management role assigned to your account1. This role grants the necessary permissions to retrieve management role assignments.

    *** GA Users are granted ApplicationPermission privileges. 
    *** Exchange Online, the concept of “All Group Members” direct assignment refers to how permissions are granted to users within a role group. 

    Ref:  https://learn.microsoft.com/en-us/exchange/permissions-exo/feature-permissions
 #>

# Connect to Exchange Online (you may need to authenticate)
Connect-ExchangeOnline

# Retrieve all users w/ ApplicationImpersonation roles assigned. 
$roleAssignments = Get-ManagementRoleAssignment -Role "ApplicationImpersonation" -GetEffectiveUsers | Where-Object {$_.EffectvieUserName -ne "All Group Memebers"}

# Initialize and store in array.
$impersonationResults = @()

# Add results to custom object.
foreach($assignment in $roleAssignments)
{
    # Get userPrincipalName for each objectGUID.
    if($assignment.EffectiveUserName -notmatch "All Group Members")
    {
        $userPrincipalName = Get-User $assignment.EffectiveUserName
    }
    else {
        $userPrincipalName.UserPrincipalName = $null
    }
 
    # Add results to custom PS object.
    $resultObject = [PSCustomObject]@{
        RoleAssigneeName = $assignment.RoleAssigneeName
        Role = $assignment.Role
        EffectiveUserName = $assignment.EffectiveUserName
        AssignmentMethod = $assignment.AssignmentMethod
        UserPrincpalName = $userPrincipalName.UserPrincipalName
    }

    $impersonationResults += $resultObject
}

$impersonationResults | Format-Table -AutoSize




