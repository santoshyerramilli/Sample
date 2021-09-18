1. For creating the 3-tier architecture we require App service for deploying web application and Sql database for the backend.
2. AppService Plan is required for hosting App Service.
3. Sql Server is required for creating database.

Steps needs to be followed for running the scripts:
--------------------------------------------------
Update the variables with the required names in files appservicedeployment.ps1,appservice.ps1,sqlseverdeployment.psq,sqldbdeployment.ps1
1. Run appservicedeployment.ps1 for creating the App Service Plan.
2. Run appservice.ps1 for creating the App Service.
3. Run sqlserver.ps1 for creating the Sql Server.
4. Run sqldb.ps1 for creating the Sql db