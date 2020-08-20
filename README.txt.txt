Commits Merged Powershell scripts

General Information:
I have two separate Powershell scripts written, one which is able to run on demand (CommitsMergedGWCP.ps1) and one that runs on AWS Lambda at 5 AM CST daily (ScheduledCommitsJobGWCP.ps1)

Installation instructions: 
# 1. create directory c:/bitbucket/
# 2. Copy script.ps1 to c:/bitbucket

Operating instructions:
# 3. run c:/bitbucket/CommitsMergedV1.0.ps1
# 4. Enter choice in prompt of which BitBucket repository you want commit details for: (1) BC, (2) CC, (3) PC, or (4) ALL? Press 1,2,3,4"
# 5. Report .csv is saved to c:/bitbucket/report.csv

Copyright and licensing information:
# This script is the property of my employer.  This is not meant to be copied or use outside but as an example of script I have written for work.

File manifest (list of files included)
# CommitsMergedGWCP.ps1
# README.txt
# report.xls
# ScheduledCommitsJobGWCP.ps1

Contact information for the programmer:
Mike Rouse
cell: 515-494-4417

Known bugs:
When running on demand powershell script, there are Set-ExecutionPolicy soft errors.  While the script produces correct output, it is not enterprise ready clean of bugs.

Troubleshooting:
You cannot have report.xls open when running the on-demand Powershell script (CommitsMergedGWCP.ps1)