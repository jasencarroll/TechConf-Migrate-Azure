# TechConf Registration Website

## Project Overview

The TechConf website allows attendees to register for an upcoming conference. Administrators can also view the list of attendees and notify all attendees via a personalized email message.

The application is currently working but the following pain points have triggered the need for migration to Azure:

- The web application is not scalable to handle user load at peak
- When the admin sends out notifications, it's currently taking a long time because it's looping through all attendees, resulting in some HTTP timeout exceptions
- The current architecture is not cost-effective

In this project, you are tasked to do the following:

- Migrate and deploy the pre-existing web app to an Azure App Service
- Migrate a PostgreSQL database backup to an Azure Postgres database instance
- Refactor the notification logic to an Azure Function via a service bus queue message

## Dependencies

You will need to install the following locally:

- [Postgres](https://www.postgresql.org/download/)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [Azure Function tools V3](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Azure Tools for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack)

## Project Instructions

### Part 1: Create Azure Resources and Deploy Web App

1. Create Resources

   ```bash
   bash resources.sh
   ```

2. DB Upload & config

   - Allow all IPs
   - Restore DB:
      - If using pgAdmin it might fail when it really worked. 
      - I found that out by using the following and then refactored and added it to my resources.sh
         ```bash
            pg_restore -h postjc998657.postgres.database.azure.com \
            -p 5432 \
            --no-tablespaces \
            -W -O -F t -x \
            -d techconfdb \
            -U sql_admin@postjc998657 \
            C:\Users\jasen\dev\migration\data\techconfdb_backup.tar
         ```
      `-W` is a force password on log in
      `-O` no need to import the owner
      `-F t` importing a tar file
      `-x` prevent restoration of access privileges
      `-d` is the database
      `-U` is the user
      - Finally is the path to the .tar file. 
      </br>

2. Update WebApp

- Open the web folder and update the following in the `config.py` file
  - `POSTGRES_URL`
  - `POSTGRES_USER`
  - `POSTGRES_PW`
  - `POSTGRES_DB`
  - `SERVICE_BUS_CONNECTION_STRING`

- Deploy WebApp

```bash
export FLASK_RUN=application.py

az webapp up \
   --resource-group $resourceGroup \
   --name $webApp \
   --sku=F1 \
   --verbose
```

That's not working so we'll get the backend going.

### Part 2: Create and Publish Azure Function

1. Create local function:

      ```bash
      func init function --python
      cd function
      pipenv install
      pipenv shell
      ```   

2. Develop the function:

   - The Azure Function should do the following:
      - Process the message which is the `notification_id`
      - Query the database using `psycopg2` library for the given notification to retrieve the subject and message
      - Query the database to retrieve a list of attendees (**email** and **first name**)
      - Loop through each attendee and send a personalized subject message
      - After the notification, update the notification status with the total number of attendees notified.
      </br>

3. Run the WebApp locally to potentially figure out why the deploy isn't working:`func start`
</br>
4. Run the FrontEnd locally:

   - In a different terminal:
   ```bash
   cd web/
   pipenv install
   pipenv shell
   export FLASK_APP=application.py
   python3 application.py
   ```

### Part 3: Refactor `routes.py`

1. Refactor the post logic in `web/app/routes.py -> notification()` using servicebus `queue_client`:
   - The notification method on POST should save the notification object and queue the notification id for the function to pick it up
2. Re-deploy the web app to publish changes

## Monthly Cost Analysis

Complete a month cost analysis of each Azure resource to give an estimate total cost using the table below:

| Azure Resource | Service Tier | Monthly Cost |
| ------------ | ------------ | ------------ |
| *Azure Postgres Database* |     |              |
| *Azure Service Bus*   |         |              |
| ...                   |         |              |

## Architecture Explanation

This is a placeholder section where you can provide an explanation and reasoning for your architecture selection for both the Azure Web App and Azure Function.
