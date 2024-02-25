
<#  
.SYNOPSIS  
    Create PIM Assignments (Entra ID Identity Governance)
.DESCRIPTION      
    
Script creates PIM Assignments to AAD Groups based on CSV input file.

.NOTES  

    File Name  : CreatePIMAssignments.ps1
     
.LINK  
#>

$username = ""
$pwd = ConvertTo-SecureString -String "" -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($username, $pwd)

Connect-AzureAD -Credential $creds -Verbose

# Get input file

$inputFile = Import-Csv '.\PIMAssignmentsInput.csv'

$tenantid = (Get-AzureADTenantDetail).objectID

# Process each entry from the source file. 
foreach($entry in $inputFile){

    # Get the role definition and group to be assigned.
    $role = Get-AzureADMSRoleDefinition -Filter "DisplayName eq '$($entry.Rolepermission)'"  
    $group = Get-AzureADGroup -Filter "DisplayName eq '$($entry.AADGroupDisplayName)'"

    # Check if role assignment exists. 
    $roleAssignment = Get-AzureADMSPrivilegedRoleAssignment -ProviderId 'aadroles' -ResourceId $tenantid | Where-Object {($_.RoleDefinitionId -eq $role.Id) -and ($_.SubjectId -eq $group.ObjectId)} 

    # Process new assignments only.
    if(!$roleAssignment)
    {
        Write-Verbose "Creating Role Assginment for Group '$($group.DisplayName)' for Role '$($role.DisplayName)' " -Verbose

        if($entry.AssignmentState -eq "Eligible")
        {

            # Get schedule
            $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
            $schedule.Type = 'Once'
            $schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            $schedule.EndDateTime = (Get-Date).AddHours($entry.durationInHours).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        
            Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -Schedule $schedule `
                -ResourceId $tenantid -RoleDefinitionId $($role.Id).ToString() -SubjectId $group.ObjectId `
                -AssignmentState $entry.AssignmentState -Type 'AdminAdd'

        } elseif ($entry.AssignmentState -eq "Active") {

            # Get schedule
            $schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
            $schedule.Type = 'Once'
            $schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            $schedule.EndDateTime = (Get-Date).AddHours($entry.durationInHours).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')

            Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId aadRoles -Schedule $schedule `
                -ResourceId $tenantid -RoleDefinitionId $($role.Id).ToString() -SubjectId $group.ObjectId `
                -AssignmentState $entry.AssignmentState -Type 'AdminAdd' -Reason $entry.Reason
            
        } else {
            Write-host "No valid value present in assignment state"
        }

    }
    else {
        Write-Host -ForegroundColor Yellow "VERBOSE: Role Assginment for Group '$($group.DisplayName)' for Role '$($role.DisplayName)' already created" -Verbose
    }

}
