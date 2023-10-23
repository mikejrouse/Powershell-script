# Powershell-script
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
