
# Date and Logging
$Date = Get-Date
$DateStr = $Date.ToString("yyyy-MM-dd-hh-mm")
$folder = "C:\ProgramData\ALU"
$LogFileName = "ALU-"+ $DateStr
$LogFile = "$folder"+"\"+"$LogFileName.Log"


# Create the new local user account
$adminUsername = "admin"
$adminFullName = "Local Admin"
$adminDescription = "Last Updated "+$DateStr

Start-Transcript $LogFile -Force

Write-Output "Checking for User installation..."

If (Get-LocalUser -Name $adminUsername -ErrorAction SilentlyContinue) { 
    Write-Output "User account with that name already exists, updating password..." 
    Try {
        If(!(test-path -PathType container $folder)) {
            New-Item -ItemType Directory -Path $folder
        }
    } Catch{
        Write-Output "Directory already exists..."
        Continue
    } 

    Try {
        Write-Output "Downloading lastest securepassword..."
        Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/GenerateSecureString/main/Password.txt" -outfile $folder"\Password.txt"
        
        # Read the encrypted password from file
        $encryptedPassword = Get-Content -Path $folder"\Password.txt" | ConvertTo-SecureString
        Remove-Item -Path $folder"\Password.txt" -Force

        $adminAccountParams = @{
            Name = $adminUsername
            Password = $encryptedPassword
            Description = $adminDescription
        }
        Set-LocalUser @adminAccountParams

        # Add the new local user account to the Administrators group
        # Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
    } Catch{ 
        $ErrorMessage = $_.Exception.Message 
        Write-Output $ErrorMessage 
    } Finally{ 
        If ($ErrorMessage) { 
            Write-Output "Something went wrong" 
            Try {
                Stop-Transcript
            } Catch {
                Write-Output "Error stopping transcript: $_"
            }
            throw $ErrorMessage 
        } Else { 
            Write-Output "User account '$adminUsername' updated successfully."
            Try {
                Stop-Transcript
            } Catch {
                Write-Output "Error stopping transcript: $_"
            }
        } 
    }
} Else{ 
    Try {
    Write-Output "User account with that name does not exists, creating user account password..." 
    Write-Output "Downloading securepassword..."
    Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/GenerateSecureString/main/Password.txt" -outfile $folder"\Password.txt"
    
    # Read the encrypted password from file
    $encryptedPassword = Get-Content -Path $folder"\Password.txt" | ConvertTo-SecureString
    $adminAccountParams = @{
        Name = $adminUsername
        FullName = $adminFullName
        Description = $adminDescription
        Password = $encryptedPassword
        PasswordNeverExpires = $true
        AccountNeverExpires = $true
    }
    New-LocalUser @adminAccountParams
    Remove-Item -Path $folder"\Password.txt" -Force

    # Add the new local user account to the Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
    
    Write-Output "User account '$adminUsername' has been created successfully." 
    
    } Catch{
        Write-Output "Error stopping transcript: $_"
        Stop-Transcript
    }
}
