# query-genie

## Configuration

Before running the application, you must fill in the required configuration files located in the `config/` directory.

### 1. `config/application.yml`
This file contains the Spring Boot datasource and JPA settings. You need to provide your PostgreSQL database connection details:

```
spring:
  datasource:
    url: jdbc:postgresql://<host_id>/<db_name>   # Replace <host_id> and <db_name> with your PostgreSQL host and database name
    username: <username>                         # Replace <username> with your database username
    password: <pwd>                             # Replace <pwd> with your database password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true
    database-platform: org.hibernate.dialect.PostgreSQLDialect
```

### 2. `config/config.ini`
This file contains additional configuration for the database and extraction utility. Fill in the following fields:

```
[postgres_db]
host = <host_id>                  # PostgreSQL host
port = 5432                       # PostgreSQL port (default: 5432)
username = <username>             # Database username
password = <pwd>                  # Database password
database = <db_name>              # Database name
schema = public                   # Database schema (default: public)
instance_id = <instance_id>       # Instance identifier

[extraction_utility]
project_id = <project_id>                 # GCP project ID
dataset_id = <dataset_id>                 # BigQuery dataset ID
service_account_file = <service_account_file>   # Path to GCP service account JSON file
region = <region>                         # GCP region
data_output_directory = <data_output_directory> # Output directory for data

[extraction_utility_logs]
days = <days>                             # Number of days for logs
logs_output_directory = <logs_dir>        # Directory for log output
log_type = <log_type>                     # Type of logs
```

**Note:** Replace all values in angle brackets (`<...>`) with your actual configuration values.

---

For further details, refer to the comments in each configuration file.


SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '1 minutes'
AND state <> 'idle';




----------------------
[postgres_db]
project_id = t-innovation
region = us-central1
instance_name = query-genie
database = postgres
iam_user = query-genie-sa@t-innovation.iam.gserviceaccount.com
schema = public

[extraction_utility]
project_id = t-innovation
dataset_id = query-genie
service_account_file = C:\Users\Lenovo\Downloads\t-innovation-cbc1c5417bd7.json
region = us-central1
data_output_directory = <data_output_directory>
bq_location = us-central1

[extraction_utility_logs]
days = <days>
logs_output_directory = <logs_dir>
log_type = <log_type>


------------------------------

How to run trulens

chmod +x run.sh

./run.sh



curl -X 'GET' \
'http://127.0.0.1:8000/health' \
-H 'accept: application/json'

curl -X 'POST' \
'http://127.0.0.1:8000/get-recommendations' \
-H 'accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
"market": "US"
}'

SELECT COUNT(DISTINCT a.userId) AS user_count
FROM AMH_FZ_FDR_DEV_SIT.cm_event_assignee_update a,
     UNNEST(a.ids) AS z

Generate only the SQL query without wrapping it in quotes or any programming language syntax.
Return the query as plain SQL, not as a string.
Do not add any quotes (' or ") around the query.

Output only the raw SQL query — no quotes, no code syntax, no explanations.
Do not wrap the query in ', ", or backticks.
Just return plain SQL.

# Remove surrounding single or double quotes if present
    if response.startswith(('"')) and response.endswith(('"')):
        return response[1:-1].strip()


JOIN AMH_FZ_FDR_DEV_SIT.event_store es
  ON z.identifier = es.lifecycle_id
WHERE PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%z', 
         REPLACE(es.sender_email_chg_date, ' +00:00', '+0000')
      ) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);



```
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 8443,
    host: '0.0.0.0',
    fs: {
      strict: false
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  }
})
```
#!/bin/bash

# Source environment variables
source /opt/app/envvars.cfg

# Set variables from environment
PROJECT_ID=${project}
CLOUDSQL_INSTANCE=${CLOUDSQL_INSTANCE}
CLOUDSQL_CONNECTION_STRING=${CLOUDSQL_CONNECTION_STRING}
CLOUDSQL_PRIVATE_IP=${CLOUDSQL_PRIVATE_IP}

# SQL queries to execute
SQL_QUERY="alter group postgres add user \"sql-reco-engine@${PROJECT_ID}.iam\";
grant all on all tables in schema public to \"sql-reco-engine@${PROJECT_ID}.iam\";
alter user \"sql-reco-engine@${PROJECT_ID}.iam\" CREATEDB CREATEROLE ;

alter group postgres add user \"query-genie@${PROJECT_ID}.iam\";
grant all on all tables in schema public to \"query-genie@${PROJECT_ID}.iam\";
alter user \"query-genie@${PROJECT_ID}.iam\" CREATEDB CREATEROLE ;

CREATE EXTENSION IF NOT EXISTS pgaudit;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

# Function to get IAM access token for Cloud SQL
get_access_token() {
    if command -v gcloud &> /dev/null; then
        gcloud auth print-access-token
    else
        echo "Error: gcloud CLI is required for IAM authentication"
        exit 1
    fi
}

# Function to execute SQL with IAM authentication
execute_sql() {
    echo "Connecting to Cloud SQL instance: $CLOUDSQL_INSTANCE"
    echo "Project ID: $PROJECT_ID"
    echo "Using IAM authentication..."
    
    # Get current IAM user
    IAM_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
    echo "Current IAM user: $IAM_USER"
    
    # Method 1: Using gcloud sql connect with IAM (recommended)
    if command -v gcloud &> /dev/null; then
        echo "Using gcloud sql connect with IAM authentication..."
        
        # First, get an access token and use it as password
        ACCESS_TOKEN=$(get_access_token)
        
        # Connect using the IAM user
        PGPASSWORD="$ACCESS_TOKEN" echo "$SQL_QUERY" | gcloud sql connect "$CLOUDSQL_INSTANCE" \
            --project="$PROJECT_ID" \
            --user="$IAM_USER" \
            --database=postgres
    
    # Method 2: Using psql with Cloud SQL Proxy and IAM
    elif [ -n "$CLOUDSQL_PRIVATE_IP" ] && command -v psql &> /dev/null; then
        echo "Using psql with IAM authentication..."
        
        ACCESS_TOKEN=$(get_access_token)
        
        # Use the access token as password for IAM authentication
        PGPASSWORD="$ACCESS_TOKEN" echo "$SQL_QUERY" | psql \
            -h "$CLOUDSQL_PRIVATE_IP" \
            -U "$IAM_USER" \
            -d postgres \
            -p 5432
    
    # Method 3: Using connection string with IAM
    elif [ -n "$CLOUDSQL_CONNECTION_STRING" ] && command -v psql &> /dev/null; then
        echo "Using connection string with IAM authentication..."
        
        ACCESS_TOKEN=$(get_access_token)
        
        # Modify connection string to include IAM user and token
        MODIFIED_CONNECTION_STRING=$(echo "$CLOUDSQL_CONNECTION_STRING" | sed "s/user=[^[:space:]]*/user=$IAM_USER/")
        
        PGPASSWORD="$ACCESS_TOKEN" echo "$SQL_QUERY" | psql "$MODIFIED_CONNECTION_STRING"
    
    else
        echo "Error: No suitable connection method found for IAM authentication."
        echo "Please ensure:"
        echo "1. gcloud CLI is installed and authenticated"
        echo "2. Your IAM account has Cloud SQL Client role"
        echo "3. IAM database authentication is enabled on your Cloud SQL instance"
        echo "4. Your IAM user exists as a database user in the Cloud SQL instance"
        exit 1
    fi
}

# Error handling
set -e
trap 'echo "Script failed at line $LINENO"' ERR

# Validate required variables and IAM setup
if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID is not set"
    exit 1
fi

if [ -z "$CLOUDSQL_INSTANCE" ]; then
    echo "Error: CLOUDSQL_INSTANCE is not set"
    exit 1
fi

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null; then
    echo "Error: No active gcloud authentication found"
    echo "Please run: gcloud auth login"
    exit 1
fi

# Verify IAM permissions
echo "Checking IAM permissions..."
IAM_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
echo "Will connect as IAM user: $IAM_USER"

# Execute the SQL
echo "Starting SQL execution..."
execute_sql

if [ $? -eq 0 ]; then
    echo "SQL queries executed successfully!"
else
    echo "Error executing SQL queries"
    exit 1
fi
