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

# Run the application with:
# java -Dspring.config.location=file:/path/to/config/application.yml \
#      -DINSTANCE_CONNECTION_NAME=your-project:region:instance-name \
#      -DDB_NAME=recommendations \
#      -DDB_USER=your-service-account@project.iam.gserviceaccount.com \
#      -DGOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json \
#      -jar query-genie-1.0.0.jar
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
