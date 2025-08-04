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
execute_sql() {
    echo "Connecting to Cloud SQL instance: $CLOUDSQL_INSTANCE"
    echo "Project ID: $PROJECT_ID"
    
    # Method 1: Using gcloud sql connect (recommended for Cloud SQL)
    if command -v gcloud &> /dev/null; then
        echo "Using gcloud sql connect..."
        echo "$SQL_QUERY" | gcloud sql connect "$CLOUDSQL_INSTANCE" \
            --project="$PROJECT_ID" \
            --user=postgres \
            --database=postgres
    
    # Method 2: Using psql with connection string (if available)
    elif [ -n "$CLOUDSQL_CONNECTION_STRING" ] && command -v psql &> /dev/null; then
        echo "Using psql with connection string..."
        echo "$SQL_QUERY" | psql "$CLOUDSQL_CONNECTION_STRING"
    
    # Method 3: Using psql with individual connection parameters
    elif [ -n "$CLOUDSQL_PRIVATE_IP" ] && command -v psql &> /dev/null; then
        echo "Using psql with private IP..."
        echo "$SQL_QUERY" | psql -h "$CLOUDSQL_PRIVATE_IP" \
            -U postgres \
            -d postgres \
            -p 5432
    
    else
        echo "Error: No suitable connection method found."
        echo "Please ensure either:"
        echo "1. gcloud CLI is installed and authenticated"
        echo "2. psql is installed and CLOUDSQL_CONNECTION_STRING is set"
        echo "3. psql is installed and CLOUDSQL_PRIVATE_IP is set"
        exit 1
    fi
}

# Error handling
set -e
trap 'echo "Script failed at line $LINENO"' ERR

# Validate required variables
if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID is not set"
    exit 1
fi

if [ -z "$CLOUDSQL_INSTANCE" ]; then
    echo "Error: CLOUDSQL_INSTANCE is not set"
    exit 1
fi

# Execute the SQL
echo "Starting SQL execution..."
execute_sql

if [ $? -eq 0 ]; then
    echo "SQL queries executed successfully!"
else
    echo "Error executing SQL queries"
    exit 1
fi
