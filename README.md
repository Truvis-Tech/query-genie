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

import os
import argparse
import logging
import sys
from google.cloud import bigquery
from google.oauth2 import service_account
from google.auth import default
from datetime import datetime
import yaml
import re
import traceback
import configparser
import argparse
import pandas as pd
import socket
import urllib3
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter
import requests

def setup_connection_settings():
    """Configure connection settings for VDI environments"""
    # Disable SSL warnings if needed
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    
    # Set timeout values
    socket.setdefaulttimeout(30)
    
    # Configure proxy if needed (uncomment and modify if you have proxy)
    # os.environ['HTTP_PROXY'] = 'http://your-proxy:port'
    # os.environ['HTTPS_PROXY'] = 'https://your-proxy:port'
    
    # Set DNS timeout
    os.environ['GOOGLE_CLOUD_REQUEST_TIMEOUT'] = '60'
    
    # Force use of service account instead of OAuth flow
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'path/to/service-account.json'
    parser = argparse.ArgumentParser()
    parser.add_argument('--config-path', default=None)
    args, _ = parser.parse_known_args()  

    env_config_path = os.environ.get('CONFIG_PATH')
    default_path = os.path.abspath('./extraction_utility/config/config.ini')

    config_path = args.config_path or env_config_path or default_path
    if config_path and not os.path.exists(config_path):
        config_path = default_path

    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config file not found: {config_path}")

    return config_path

def load_config():
    """Get BigQuery project, region, dataset(s), output_dir information from config"""
    config_path = load_config()
    config = configparser.ConfigParser()
    config.read(config_path)
    try:
        section = 'extraction_utility'
        project_id = config.get(section, 'project_id')
        region = config.get(section, 'region')
        dataset_id = config.get(section, 'dataset_id').strip()
        output_dir = config.get(section, 'data_output_directory')
        
        # Try to get service account file, but make it optional
        service_account_file = config.get(section, 'service_account_file', fallback=None)

        # Use service account if available, otherwise use default credentials
        if service_account_file and os.path.exists(service_account_file):
            logging.info("Using service account credentials")
            credentials = service_account.Credentials.from_service_account_file(service_account_file)
            client = bigquery.Client(credentials=credentials, project=project_id)
        else:
            logging.info("Using application default credentials")
            credentials, _ = default()
            client = bigquery.Client(credentials=credentials, project=project_id)

        # If dataset_id is empty, fetch all datasets in the project
        if not dataset_id:
            datasets = [d.dataset_id for d in client.list_datasets(project=project_id)]
        else:
            # Split by comma and strip whitespace
            datasets = [d.strip() for d in dataset_id.split(',') if d.strip()]

        return client, project_id, region, datasets, output_dir
    except configparser.NoOptionError as e:
        raise ValueError(f"Missing configuration option: {e}")

def setup_logging(verbose):
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=level)

def load_queries(filepath):
    try:
        with open(filepath, 'r') as file:
            return yaml.safe_load(file)
    except yaml.YAMLError as e:
        logging.error(f"Error loading queries from {filepath}: {e}")
        raise ValueError(f"Invalid YAML file: {filepath}")

def run_query(client, query):
    """Run query with retry logic for network issues"""
    max_retries = 3
    for attempt in range(max_retries):
        try:
            job_config = bigquery.QueryJobConfig(
                use_query_cache=True,
                job_timeout_ms=300000,  # 5 minutes
            )
            
            query_job = client.query(query, job_config=job_config)
            return query_job.to_dataframe()
            
        except Exception as e:
            if attempt < max_retries - 1:
                logging.warning(f"Query attempt {attempt + 1} failed: {e}. Retrying...")
                import time
                time.sleep(5 * (attempt + 1))  # Exponential backoff
            else:
                logging.error(f"Query failed after {max_retries} attempts: {e}")
                raise

def save_to_parquet(df, output_dir, project_id, region, dataset, name):
    """Save the dataframe to a parquet file"""
    try:
        dataset_path = output_dir
        os.makedirs(dataset_path, exist_ok=True)

        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{name}.{timestamp}.parquet"
        filepath = os.path.join(dataset_path, filename)

        # Save dataframe to parquet with compression
        df.to_parquet(filepath, index=False, compression='snappy')
        return filepath
    except Exception as e:
        logging.error(f"Error saving to parquet: {e}")
        raise

def extract_table_name(sql_text):
    try:
        match = re.search(r"FROM\s+`?(?:[\w-]+\.){1,2}([\w-]+)`?", sql_text, re.IGNORECASE)
        return match.group(1).lstrip("__") if match else "unknown_table_name"
    except Exception as e:
        logging.error(f"Error extracting table name from SQL: {e}")
        raise

def main():
    # Setup connection settings for VDI
    setup_connection_settings()
    
    try:
        client, project_id, region, datasets, output_dir = get_creds()
        setup_logging(verbose=True)

        logging.info(f"Fetching schema information from {project_id} datasets: {datasets} ...")
        queries = load_queries(os.path.abspath(os.path.join(os.path.dirname(__file__),"queries.yaml")))

        for name, query in queries.items():
            try:
                # Only run TABLES__ logic for query6
                if name == "query6":
                    all_tables_df = []
                    for dataset_id in datasets:
                        print(f"Processing dataset: {dataset_id}")
                        formatted_query = query.format(region=region, dataset=dataset_id, project_id=project_id)
                        print(f"Query for {dataset_id}: {formatted_query}")
                        df = run_query(client, formatted_query)
                        print(f"Rows returned for {dataset_id}: {len(df)}")
                        all_tables_df.append(df)
                    if all_tables_df:
                        combined_df = pd.concat(all_tables_df, ignore_index=True)
                        print(f"Total rows after concat: {len(combined_df)}")
                        table_name = extract_table_name(query)
                        filepath = save_to_parquet(combined_df, output_dir, project_id, region, 'ALL_DATASETS', table_name)
                        logging.info(f"Successfully saved {len(combined_df)} rows of schema information to:")
                        logging.info(filepath)
                        logging.info(f"File size: {os.path.getsize(filepath) / (1024 * 1024):.2f} MB")
                    else:
                        logging.warning("No __TABLES__ data found for any dataset.")
                else:
                    dataset_id = datasets[0]
                    formatted_query = query.format(region=region, dataset=dataset_id, project_id=project_id)
                    table_name = extract_table_name(formatted_query)
                    df = run_query(client, formatted_query)
                    filepath = save_to_parquet(df, output_dir, project_id, region, dataset_id, table_name)
                    logging.info(f"Successfully saved {len(df)} rows of schema information to:")
                    logging.info(filepath)
                    logging.info(f"File size: {os.path.getsize(filepath) / (1024 * 1024):.2f} MB")
            except Exception as e:
                logging.error(f"Error processing {name}: {str(e)}")
                traceback.print_exc()
                continue  # Continue with other queries even if one fails

    except Exception as e:
        logging.error(f"Fatal error: {str(e)}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
