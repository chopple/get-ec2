function Get-EC2 {
    [cmdletBinding()]

    param 
    (
        [string]$ec2det
    )

    Try {
        switch -Regex ($ec2det) {
            
            '^(?!i-)[a-zA-Z]' { $ec2filter = @{name = 'tag:Name'; values = "*" + "$ec2det" + "*" }
                $InstanceDet = get-ec2instance -filter $ec2filter
                $properties = [ordered]@{id = $instancedet.instances.instanceid
                    Type                    = $InstanceDet.instances.instancetype
                    PrivateIP               = $InstanceDet.instances.PrivateIpAddress 
                    OS                      = $InstanceDet.instances.Platform
                    Name                    = $InstanceDet.instances.tag | Where-Object { $_.key -eq 'Name' } | select-object -ExpandProperty value 
                    Running                 = $InstanceDet.instances.state | select-object -ExpandProperty   name
                    VpcId                   = $InstanceDet.instances.vpcid
                }
                $obj = New-Object -TypeName psobject -Property $properties 
        
            }
            '^i-*' {
                $InstanceDet = get-ec2instance -instanceid $ec2det
                $properties = [ordered]@{id = $instancedet.instances.instanceid
                    Type                    = $InstanceDet.instances.instancetype
                    PrivateIP               = $InstanceDet.instances.PrivateIpAddress 
                    OS                      = $InstanceDet.instances.Platform
                    Name                    = $InstanceDet.instances.tag | Where-Object { $_.key -eq 'Name' } | select-object -ExpandProperty value 
                    Running                 = $InstanceDet.instances.state | select-object -ExpandProperty   name
                    VpcId                   = $InstanceDet.instances.vpcid
                }
                $obj = New-Object -TypeName psobject -Property $properties 
            }
            '(\d{1,3}\.){3}\d{1,3}' { $ec2filter = @{name = 'network-interface.addresses.private-ip-address'; values = "$ec2det" } 
                $InstanceDet = get-ec2instance -filter $ec2filter
                $properties = [ordered]@{id = $instancedet.instances.instanceid
                    Type                    = $InstanceDet.instances.instancetype
                    PrivateIP               = $InstanceDet.instances.PrivateIpAddress 
                    OS                      = $InstanceDet.instances.Platform 
                    Name                    = $InstanceDet.instances.tag | Where-Object { $_.key -eq 'Name' } | select-object -ExpandProperty value 
                    Running                 = $InstanceDet.instances.state | select-object -ExpandProperty   name
                    VpcId                   = $InstanceDet.instances.vpcid
                }
                $obj = New-Object -TypeName psobject -Property $properties 
       
            }
        }
    }
    Catch { Write-Output "Unknown Input.  Please enter a Host name, an Instnace name or an IP address - wildcards (*) are assummed.  If you entered the correct name the instance may not exist" }

    #write-output $obj
    if ($obj.type.count -lt 2) {
    
        write-output $obj
    }
    else {
        for ($i = 0; $i -lt $obj.type.Count; $i++) {
            write-output "$($obj.id[$i]),$($obj.Type[$i]),$($obj.PrivateIP[$i]),$($obj.name[$i]),$($obj.running[$i]),$($obj.VpcId[$i])"
        }
    }
}