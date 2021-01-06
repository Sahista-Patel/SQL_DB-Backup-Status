# SQL_DB-Backup-Status
This script will check the status of the database backup. It gives the number of days since last backup taken. If threshold is set (example 30 days), then it will mark that cell as RED as backup is not done otherwise GREEN. Gives the email alert as well as HTML file with the table of all database backup status with required details for passed servers in server list.

The Server Name, Process Status, Process Name, Display Name, Database Name, Recovery Model, Last Backup Date and Time, Last Full Backup Start Date, Last Full Backup End Date, Last Full Backup Size, Last Differential Backup Start Date, Last Differential Backup End Date, Last Differential Backup Size, Last Log Backup Start Date, Last Log Backup End Date, Last Log Backup Size, Days Since Last Backup all these details Server and Instancewise will be formatted in fine table. It will send an email, if scheduled then it is monitoring technique for Database backup status on bunch of servers.

## Prerequisites

Windows OS - Powershell<br>
SqlServer Module need to be installed if not than type below command in powershell prompt.<br>
Install-Module -Name SqlServer

## Note
  
Server Name - Name of the target Machine<br>
Instance Name - SQL Instance<br>
DB Name	- Database Name<br>
Recovery Model - Type of Recovery Model like SIMPLE or FULL<br>
Last Backup - Last Backup Date & Time<br>
Last Full Backup Start Date	- Specifically last Full backup Start Date & Time<br>
Last Full Backup End Date	- Specifically last Full backup End Date & Time<br>
Last Full Backup Size	- Specifically last Full backup size<br>
Last Differential Backup Start Date	- Specifically last Differential backup Start Date & Time<br>
Last Differential Backup End Date	- Specifically last Differential backup End Date & Time<br>
Last Differential Backup Size	- Specifically last Differential backup size<br>
Last Log Backup Start Date - Specifically last Log backup Start Date & Time<br>
Last Log Backup End Date - Specifically last Log backup End Date & Time<br>
Last Log Backup Size - Specifically last Log backup size<br>
Days Since Last Backup - Number of days since last backup taken. If grether threshold then marked as RED otherwise GREEN<br>

## Use

Open Powershell
"C:\BackupReport.ps1"


# Input
Server list file path to (example) {$path = "C:\server_list.txt"}<br>
The output file path to (example) {$HTML = "C:\backup_report.html"}<br>
Set Email From (example) {$EmailFrom = “example@outlook.com”}<br>
Set Email To (example) {$EmailTo = “example@outlook.com"}<br>
Set Email Subject (example) {$Subject = “Disk Space Status”}<br>
Set SMTP Server Details (example) {<br> 
$SMTPServer = “smtp.outlook.com” <br>
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)<br>
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“example@outlook.com”, “Password”);}

## Example O/P

![alt text](https://github.com/Sahista-Patel/SQL_DB-Backup-Status/blob/Powershell/backup.PNG)

## License

Copyright 2020 Harsh & Sahista

## Contribution

* [Harsh Parecha] (https://github.com/TheLastJediCoder)
* [Sahista Patel] (https://github.com/Sahista-Patel)<br>
We love contributions, please comment to contribute!

## Code of Conduct

Contributors have adopted the Covenant as its Code of Conduct. Please understand copyright and what actions will not be abided.
