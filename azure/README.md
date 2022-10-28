# Azure Scripts
These are the simple small scripts shared for solving basic tasks in SharePoint

## 🚫 Disclaimer
These scripts are delivere "as is", and I do expected you check them before running them in a production environment.
Even though I do my best to put in failsafes in my live scripts, they are usually tested once or twice in my environment.


### Get-TenantID
This finds your tenant ID based on domain name and returns the value.

### FileToBlob
**This feature has two function**
- ApiToExcel -> Convert API request to an Excel File and save it in script folder.
- FileToBlob -> Pipe as file to upload it to Azure Blob Storage.

Requires the config.template.json to be populated and renamed to config.json 