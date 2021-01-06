<#
.SYNOPSIS
    This script will check the status of the database backup. It gives the number of days since last backup taken. 
    If threshold is set (example 30 days), then it will mark that cell as RED as backup is not done otherwise GREEN.
    Gives the email alert as well as HTML file with the table of all database backup status with required details for passed servers in server list.
    
.DESCRIPTION
    The Server Name, Process Status, Process Name, Display Name,
    Database Name, Recovery Model, Last Backup Date and Time, 
    Last Full Backup Start Date, Last Full Backup End Date, Last Full Backup Size,
    Last Differential Backup Start Date, Last Differential Backup End Date, 
    Last Differential Backup Size, Last Log Backup Start Date, Last Log Backup End Date,
    Last Log Backup Size, Days Since Last Backup all these details Server and Instancewise will be formatted in fine table.
    It will send an email, if scheduled then it is monitoring technique for Database backup status on bunch of servers.
    
.INPUTS
    Server List - txt file with the name of the machines/servers which to examine.
    Please set varibles like server list path, output file path, E-Mail id and password as and when guided by comment through code.

.EXAMPLE
    .\BackupReport.ps1
    This will execute the script and gives HTML file and email with the details in body.

.NOTES
    PUBLIC
    SqlServer Module need to be installed if not than type below command in powershell prompt.
    Install-Module -Name SqlServer

.AUTHOR & OWNER
    Harsh Parecha
    Sahista Patel
#>


Import-Module SqlServer

#Set Email From
$EmailFrom = “example@outlook.com”

#Set Email To
$EmailTo = “example@outlook.com"

#Set Email Subject
$Subject = “Backup-Report”

#Set SMTP Server Details
$SMTPServer = “smtp.outlook.com”

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)

$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“example@outlook.com”, “Password”);

$ServerList = "C:\server_list.txt"
$HTML = "C:\backup_report.html"
$count = 0
$Row = @()

$date = Get-Date

$obj=Get-Content -Path $ServerList

$Precheck = "{"

$id = 0

$Row = '<html>
            <head>
                <style type="text/css">
                    .tftable {font-size:12px;color:#333333;width:100%;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
                    .tftable th {font-size:12px;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;}
                    .caption1 {font-size:28px;background-color:#e6983b;border-width: 1px; height: 35px;border-style: solid;border-color: #729ea5;text-align:left; vertical-align:middle; font-weight: bold;}
                    .tftable tr {background-color:#ffffff;}
                    .tftable td {font-size:12px;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;}
                    .tftable tr:hover {background-color:#ffff99;}
                    .Success {background-color:#ff3300;}
                    .Failed {background-color:#33cc33;}
                </style>
                <title>Backup Status</title>
            </head>
            <h2>Backup Status on '+ $date +'</h2>
            <body>'

[System.IO.File]::ReadLines($ServerList) | ForEach-Object {
    
    try{
        
        $count += 1
      
        $ol = Get-WmiObject -Class Win32_Service -ComputerName "$_"
    if ($ol -ne $null){
        $Inst_list = $_ | Foreach-Object {Get-ChildItem -Path "SQLSERVER:\SQL\$_"} 
        $Row += "<div class='caption1'>"+ $_ +"</div><table class='tftable' border='1'>
                        <th style='background-color:#3399ff; font-size:15px; font-weight: bold; border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;'>"+$Inst_list+"</th>
                     </tr> 
                     <tr>
                        <th>DB Name</th>
                        <th>Recovery Model</th>
                        <th>Last Backup</th>
                        <th>Last Full Backup Start Date</th>
                        <th>Last Full Backup End Date</th>
                        <th>Last Full Backup Size</th>
                        <th>Last Differential Backup Start Date</th>
                        <th>Last Differential Backup End Date</th>
                        <th>Last Differential Backup Size</th>
                        <th>Last Log Backup Start Date</th>
                        <th>Last Log Backup End Date</th>
                        <th>Last Log Backup Size</th>
                        <th>Days Since Last Backup</th>
                     </tr>"

           
        Foreach ($Inst_list_item in $Inst_list){
                
                $Result = Invoke-Sqlcmd -Query "WITH backupsetSummary
          AS ( SELECT   bs.database_name ,
                        bs.type bstype ,
                        MAX(backup_finish_date) MAXbackup_finish_date
               FROM     msdb.dbo.backupset bs
               GROUP BY bs.database_name ,
                        bs.type
             ),
        MainBigSet
          AS ( SELECT   
                        @@SERVERNAME servername,
                        db.name ,
                        db.state_desc ,
                        db.recovery_model_desc ,
                        bs.type ,
                        convert(decimal(10,2),bs.backup_size/1024.00/1024) backup_sizeinMB,
                        bs.backup_start_date,
                        bs.backup_finish_date,
                        physical_device_name,
                        DATEDIFF(MINUTE, bs.backup_start_date, bs.backup_finish_date) AS DurationMins
                        FROM     master.sys.databases db
                        LEFT OUTER JOIN backupsetSummary bss ON bss.database_name = db.name
                        LEFT OUTER JOIN msdb.dbo.backupset bs ON bs.database_name = db.name
                                                              AND bss.bstype = bs.type
                                                              AND bss.MAXbackup_finish_date = bs.backup_finish_date
                        JOIN msdb.dbo.backupmediafamily m ON bs.media_set_id = m.media_set_id
                        where  db.database_id>4
             )
            
SELECT
    name,
    recovery_model_desc,
    Last_Backup      = MAX(a.backup_finish_date),  
    Last_Full_Backup_start_Date = MAX(CASE WHEN A.type='D' 
                                        THEN a.backup_start_date ELSE NULL END),
    Last_Full_Backup_end_date = MAX(CASE WHEN A.type='D' 
                                        THEN a.backup_finish_date ELSE NULL END),
    Last_Full_BackupSize_MB=  MAX(CASE WHEN A.type='D' THEN backup_sizeinMB  ELSE NULL END),
    Full_DurationSeocnds = MAX(CASE WHEN A.type='D' 
                                        THEN DATEDIFF(SECOND, a.backup_start_date, a.backup_finish_date) ELSE NULL END),
    Last_Full_Backup_path = MAX(CASE WHEN A.type='D' 
                                        THEN a.physical_Device_name ELSE NULL END),
    Last_Diff_Backup_start_Date = MAX(CASE WHEN A.type='I' 
                                        THEN a.backup_start_date ELSE NULL END),
    Last_Diff_Backup_end_date = MAX(CASE WHEN A.type='I' 
                                         THEN a.backup_finish_date ELSE NULL END),
    Last_Diff_BackupSize_MB=  MAX(CASE WHEN A.type='I' THEN backup_sizeinMB  ELSE NULL END),
    Diff_DurationSeocnds = MAX(CASE WHEN A.type='I' 
                                        THEN DATEDIFF(SECOND, a.backup_start_date, a.backup_finish_date) ELSE NULL END),
    Last_Log_Backup_start_Date = MAX(CASE WHEN A.type='L' 
                                        THEN a.backup_start_date ELSE NULL END),
    Last_Log_Backup_end_date = MAX(CASE WHEN A.type='L' 
                                         THEN a.backup_finish_date ELSE NULL END),
    Last_Log_BackupSize_MB=  MAX(CASE WHEN A.type='L' THEN backup_sizeinMB  ELSE NULL END),
    Log_DurationSeocnds = MAX(CASE WHEN A.type='L' 
                                        THEN DATEDIFF(SECOND, a.backup_start_date, a.backup_finish_date) ELSE NULL END),
    Last_Log_Backup_path = MAX(CASE WHEN A.type='L' 
                                        THEN a.physical_Device_name ELSE NULL END),
    [Days_Since_Last_Backup] = DATEDIFF(d,(max(a.backup_finish_Date)),GETDATE())
FROM
    MainBigSet a
group by 
     servername,
     name,
     state_desc,
     recovery_model_desc
--  order by name,backup_start_date desc;" -ServerInstance $Inst_list_item.Name
                $sqlCount = 0
            
                ForEach($line in $Result){
                    $sqlCount += 1
                    if ($line.Days_Since_Last_Backup-lt 30)
                    {$st = "Failed"}
                     else 
                    {$st = "Success"}
                    $Row += "<tr>
                                <td>"+ $line.name +"</td>
                                <td>"+ $line.recovery_model_desc +"</td>
                                <td>"+ $line.Last_Backup +"</td>
                                <td>"+ $line.Last_Full_Backup_start_Date +"</td>
                                <td>"+ $line.Last_Full_Backup_end_date +"</td>
                                <td>"+ $line.Last_Full_BackupSize_MB +"</td>
                                <td>"+ $line.Last_Diff_Backup_start_Date +"</td>
                                <td>"+ $line.Last_Diff_Backup_start_Date +"</td>
                                <td>"+ $line.Last_Diff_Backup_end_date +"</td>
                                <td>"+ $line.Last_Log_Backup_start_Date +"</td>
                                <td>"+ $line.Last_Log_Backup_end_date +"</td>
                                <td>"+ $line.Last_Log_BackupSize_MB +"</td>
                                <td class='"+$st+"'>"+ $line.Days_Since_Last_Backup +"</td>
                             </tr>"
                }          

            }

            $Row += "</table></br/br>"

    }
    }
    catch{

    }
   }

$Row += "</body></html>"

Set-Content $HTML $Row

$Body = $Row

$SMTPClient.EnableSsl = $true

# Create the message
$mail = New-Object System.Net.Mail.Mailmessage $EmailFrom, $EmailTo, $Subject, $Body

$mail.IsBodyHTML=$true

$SMTPClient.Send($mail)