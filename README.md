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
---------------------------Case Insensitive------------------------------:
-- Query 1
UPDATE AMH_FZ_REPORT_MARTS_TABLES_DEV.Account_Level 
SET stateid = 'genuine', 
    load_datetime = TIMESTAMP('2025-06-29 16:00:00+00') 
WHERE report_name = 'Confirmed Fraud' 
  AND lifecycle_id IN (
    SELECT DISTINCT identifier 
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum 
        FROM AMH_FZ_FDR_DEV_SIT.cm_event_state_updates_vw 
        WHERE (
            (username IS NULL 
             AND LOWER(name) IN (
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             )
            ) 
            OR (username != 'system' 
                AND LOWER(state.id) IN (
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                )
            )
        ) 
        AND LOWER(channelId) IN ('digital-activity', 'transfers') 
        AND updatedTimestamp >= TIMESTAMP('2025-06-28 16:00:00+00')
    ) 
    WHERE rownum = 1 
      AND (
        (username IS NULL 
         AND LOWER(name) IN (
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         )
        ) 
        OR (username != 'system' 
            AND LOWER(state.id) IN (
                'genuine',
                'genuine_digital_activity'
            )
        )
    )
);

Recommendation- 
Alter SCHEMA AMH_FZ_REPORT_MARTS_TABLES_DEV
SET OPTIONS(
 is_case_insensitive=TRUE,
 
);

UPDATE AMH_FZ_REPORT_MARTS_TABLES_DEV.Account_Level AS acc
SET stateid = 'genuine',
    load_datetime = TIMESTAMP('2025-06-29 16:00:00+00')
WHERE report_name = 'Confirmed Fraud'
  AND EXISTS (
    SELECT 1
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum
        FROM AMH_FZ_FDR_DEV_SIT.cm_event_state_updates_vw
        WHERE (
            (username IS NULL
             AND LOWER(name) IN UNNEST([
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             ])
            )
            OR (username != 'system'
                AND LOWER(state.id) IN UNNEST([
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                ])
            )
        )
        AND LOWER(channelId) IN UNNEST(['digital-activity', 'transfers'])
        AND updatedTimestamp >= TIMESTAMP('2025-06-28 16:00:00+00')
    ) filtered
    WHERE filtered.rownum = 1
      AND (
        (username IS NULL
         AND LOWER(name) IN UNNEST([
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         ])
        )
        OR (username != 'system'
            AND LOWER(state.id) IN UNNEST([
                'genuine',
                'genuine_digital_activity'
            ])
        )
      )
      AND acc.lifecycle_id = filtered.identifier
);


-- Query 2
INSERT INTO HASE_FZ_REPORT_MARTS_TABLES_DEV.Payment_Mart (
    report_name, create_timestamp, action_alert_timestamp, result_on_alert_timestamp,
    entity, portfolio, channel, class, final_portfolio, statemachineID, final_state,
    payment_source, transaction_status, sender_transaction_currency,
    number_of_payment_customers, sum_of_transaction_amount_usd,
    sum_of_transaction_amount_original, count_of_alerts, number_of_alerted_customers,
    sum_of_transaction_amount_gbp, sum_of_transaction_amount_gbp_by_alerts,
    lob, timestamp
)
SELECT
    'Payment Mart' AS report_name,
    final_set.create_timestamp AS create_timestamp,
    final_set.action_on_alert_timestamp,
    final_set.result_on_alert_timestamp,
    final_set.entity AS entity,
    final_set.portfolio AS portfolio,
    CASE
        WHEN LOWER(final_set.channel) = 'c' THEN 'Payment Card at Card Reader Terminal (including online purchase and ATM)'
        WHEN LOWER(final_set.channel) = 'd' THEN 'Payment Card or Number with Online Details and Device Fingerprint Information'
        WHEN LOWER(final_set.channel) = 'e' THEN 'Payment Card or Number with Online Details'
        WHEN LOWER(final_set.channel) = 'o' THEN 'Online Banking (internet, mobile phone)'
        WHEN LOWER(final_set.channel) = 'w' THEN 'Online Banking with device fingerprint information'
        WHEN LOWER(final_set.channel) = 'h' THEN 'Self Bank Branch'
        WHEN LOWER(final_set.channel) = 'b' THEN 'Bank Processing (including bank initiated non-manual debit, EFT processing)'
        WHEN LOWER(final_set.channel) = 'r' THEN 'Other'
        WHEN LOWER(final_set.channel) = 's' THEN 'Merchant - Acquirer Processing'
        WHEN LOWER(final_set.channel) = 'u' THEN 'Unknown'
        WHEN LOWER(final_set.channel) = 'n' THEN 'NA'
        ELSE final_set.channel
    END AS channel,
    final_set.class AS class,
    final_set.final_portfolio,
    final_set.statemachineID,
    final_set.final_state,
    final_set.payment_source,
    final_set.transaction_status,
    final_set.sender_transaction_currency,
    final_set.number_of_payment_customers,
    final_set.sum_of_transaction_amount_usd,
    final_set.sum_of_transaction_amount_original,
    final_set.count_of_alerts,
    final_set.number_of_alerted_customers,
    final_set.sum_of_transaction_amount_gbp,
    final_set.sum_of_transaction_amount_gbp_by_alerts,
    'GPB' AS lob,
    TIMESTAMP('2025-06-29 16:00:00+00') AS load_datetime
FROM (
    SELECT 
        cm_event_arrival.id.identifier,
        cm_event_arrival.id.payload.schema.customer_portfolio_class,
        cm_event_arrival.id.payload.schema.customer_portfolio_country,
        cm_event_arrival.id.payload.schema.statemachineid,
        cm_event_arrival.id.payload.schema.state,
        cm_event_arrival.id.payload.schema.channel_type,
        cm_event_arrival_alert.id.identifier,
        event_store.customer_id,
        event_store_alert.customer_id,
        event_store.customer_type,
        event_store_alert.customer_type,
        event_store.event_type,
        event_store.channel,
        event_store.portfolio,
        event_store.transaction_status,
        event_store.sender_transaction_currency,
        event_store.sum_of_transaction_amount_usd,
        event_store.sum_of_transaction_amount_gbp,
        event_store.sum_of_transaction_amount_original,
        event_store.sum_of_transaction_amount_hkd,
        event_store.sum_of_transaction_amount_by_alerts,
        event_store.count_of_alerts,
        event_store.number_of_alerted_customers,
        event_store.class,
        event_store.payment_source,
        event_store.sum_of_transaction_amount_gbp_by_alerts,
        cm_event_arrival.id.channelid,
        cm_event_arrival_alert.id.channelid,
        cm_event_arrival.id.timestamp,
        cm_event_arrival_alert.id.timestamp,
        cm_event_state_updates.state,
        cm_event_state_updates.updatedAt,
        cm_event_state_updates.status,
        cm_event_state_updates.status_digital_activity,
        cm_event_state_updates.statemachineId,
        cm_event_state_updates.identifier,
        cm_event_state_updates.name,
        cm_event_state_updates.class
    FROM HASE_FZ_FDR_DEV_SIT.cm_event_arrival
    LEFT JOIN HASE_FZ_FDR_DEV_SIT.cm_event_arrival_alert 
      ON cm_event_arrival.id.identifier = cm_event_arrival_alert.id.identifier
    LEFT JOIN HASE_FZ_FDR_DEV_SIT.cm_event_state_updates 
      ON cm_event_arrival.id.identifier = cm_event_state_updates.identifier
    LEFT JOIN (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum
        FROM HASE_FZ_FDR_DEV_SIT.cm_event_state_updates
    ) cm_event_state_updates_status 
    ON cm_event_arrival.id.identifier = cm_event_state_updates_status.identifier
    LEFT JOIN (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY timestamp) AS rownum
        FROM HASE_FZ_FDR_DEV_SIT.cm_event_queue_changed
    ) cm_event_queue_changed 
    ON cm_event_arrival.id.identifier = cm_event_queue_changed.identifier
    LEFT JOIN UNNEST(SPLIT(rules_triggered, ';')) AS rules_triggered
    JOIN HASE_FZ_FDR_DEV_SIT.workflow_rules_vw rules 
      ON rules.id = rules_triggered
    WHERE LOWER(cm_event_arrival.id.channelid) IN ('transfers')
    GROUP BY create_timestamp, action_on_alert_timestamp, result_on_alert_timestamp,
             entity, portfolio, channel, lob, class, final_portfolio, statemachineID,
             final_state, payment_source, transaction_status, sender_transaction_currency
) final_set;

Recommendation- 
Alter SCHEMA AMH_FZ_REPORT_MARTS_TABLES_DEV
SET OPTIONS(
 is_case_insensitive=TRUE,
 
);


---------------------------------Truncate--------------------------------------:
-- Query 1
DELETE FROM AMH_FZ_FDR_DEV_SIT.event_store_temp 
WHERE 1=1;

Recommendation -
TRUNCATE TABLE AMH_FZ_FDR_DEV_SIT.event_store_temp;

-- Query 2
DELETE FROM AMH_FZ_FDR_DEV_SIT.rules_audit_temp
WHERE 1=1;

Recommendation -
TRUNCATE TABLE AMH_FZ_FDR_DEV_SIT.rules_audit_temp;

IN with Constants:
-- Query 1
UPDATE HASE_FZ_REPORT_MARTS_TABLES_DEV.Account_Level 
SET stateid = 'genuine', 
    load_datetime = TIMESTAMP('2025-06-30 03:00:00+00') 
WHERE report_name = 'Confirmed Fraud' 
  AND lifecycle_id IN (
    SELECT DISTINCT identifier 
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum 
        FROM HASE_FZ_FDR_DEV_SIT.cm_event_state_updates_vw 
        WHERE (
            (username IS NULL 
             AND LOWER(name) IN (
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via 2w sms - decline',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             )
            ) 
            OR (username != 'system' 
                AND LOWER(state.id) IN (
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                )
            )
        ) 
        AND LOWER(channelId) IN ('digital-activity', 'transfers') 
        AND updatedTimestamp >= TIMESTAMP('2025-06-30 02:00:00+00') 
        AND updatedTimestamp < TIMESTAMP('2025-06-30 03:00:00+00')
    ) 
    WHERE rownum = 1 
      AND (
        (username IS NULL 
         AND LOWER(name) IN (
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         )
        ) 
        OR (username != 'system' 
            AND LOWER(state.id) IN (
                'genuine',
                'genuine_digital_activity'
            )
        )
    )
);

Recommended Query - 
UPDATE HASE_FZ_REPORT_MARTS_TABLES_DEV.Account_Level 
SET stateid = 'genuine', 
    load_datetime = TIMESTAMP('2025-06-30 03:00:00+00') 
WHERE report_name = 'Confirmed Fraud' 
  AND lifecycle_id IN (
    SELECT DISTINCT identifier 
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum 
        FROM HASE_FZ_FDR_DEV_SIT.cm_event_state_updates_vw 
        WHERE (
            (username IS NULL 
             AND LOWER(name) IN UNNEST([
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via 2w sms - decline',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             ])
            ) 
            OR (username != 'system' 
                AND LOWER(state.id) IN UNNEST([
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                ])
            )
        ) 
        AND LOWER(channelId) IN UNNEST(['digital-activity', 'transfers']) 
        AND updatedTimestamp >= TIMESTAMP('2025-06-30 02:00:00+00') 
        AND updatedTimestamp < TIMESTAMP('2025-06-30 03:00:00+00')
    ) 
    WHERE rownum = 1 
      AND (
        (username IS NULL 
         AND LOWER(name) IN UNNEST([
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         ])
        ) 
        OR (username != 'system' 
            AND LOWER(state.id) IN UNNEST([
                'genuine',
                'genuine_digital_activity'
            ])
        )
    )
);


-- Query 2
UPDATE AMH_FZ_REPORT_MARTS_TABLES_DEV.Account_Level 
SET stateid = 'genuine', 
    load_datetime = TIMESTAMP('2025-06-29 16:00:00+00') 
WHERE report_name = 'Confirmed Fraud' 
  AND lifecycle_id IN (
    SELECT DISTINCT identifier 
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum 
        FROM AMH_FZ_FDR_DEV_SIT.cm_event_state_updates_vw 
        WHERE (
            (username IS NULL 
             AND LOWER(name) IN (
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             )
            ) 
            OR (username != 'system' 
                AND LOWER(state.id) IN (
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                )
            )
        ) 
        AND LOWER(channelId) IN ('digital-activity', 'transfers') 
        AND updatedTimestamp >= TIMESTAMP('2025-06-28 16:00:00+00') 
        AND updatedTimestamp < TIMESTAMP('2025-06-29 16:00:00+00')
    ) 
    WHERE rownum = 1 
      AND (
        (username IS NULL 
         AND LOWER(name) IN (
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         )
        ) 
        OR (username != 'system' 
            AND LOWER(state.id) IN (
                'genuine',
                'genuine_digital_activity'
            )
        )
    )
);

Recommended Query - 
UPDATE AMH_FZ_REPORT_MARTS_TABLES_DEV.Account_Level 
SET stateid = 'genuine', 
    load_datetime = TIMESTAMP('2025-06-29 16:00:00+00') 
WHERE report_name = 'Confirmed Fraud' 
  AND lifecycle_id IN (
    SELECT DISTINCT identifier 
    FROM (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY identifier ORDER BY updatedAt DESC) AS rownum 
        FROM AMH_FZ_FDR_DEV_SIT.cm_event_state_updates_vw 
        WHERE (
            (username IS NULL 
             AND LOWER(name) IN UNNEST([
                'customer confirmed fraud via mobile messaging (2 way)',
                'customer confirmed fraud via civr - decline',
                'customer confirmed genuine via 2w sms - approve',
                'customer confirmed genuine via civr - approve',
                'confirmed genuine via email received - approve'
             ])
            ) 
            OR (username != 'system' 
                AND LOWER(state.id) IN UNNEST([
                    'fraud',
                    'fraud_digital_activity',
                    'genuine',
                    'genuine_digital_activity'
                ])
            )
        ) 
        AND LOWER(channelId) IN UNNEST(['digital-activity', 'transfers']) 
        AND updatedTimestamp >= TIMESTAMP('2025-06-28 16:00:00+00') 
        AND updatedTimestamp < TIMESTAMP('2025-06-29 16:00:00+00')
    ) 
    WHERE rownum = 1 
      AND (
        (username IS NULL 
         AND LOWER(name) IN UNNEST([
            'customer confirmed genuine via 2w sms - approve',
            'customer confirmed genuine via civr - approve',
            'confirmed genuine via email received - approve'
         ])
        ) 
        OR (username != 'system' 
            AND LOWER(state.id) IN UNNEST([
                'genuine',
                'genuine_digital_activity'
            ])
        )
    )
);


----------------------------------IN Clause with Subquery-----------------------------:
-- Query 1
SELECT folder_name 
FROM AMH_FZ_FDR_DEV_SIT.event_store_temp 
WHERE ARRAY_REVERSE(SPLIT(folder_name, '/'))[OFFSET(1)] || '/' || ARRAY_REVERSE(SPLIT(folder_name, '/'))[OFFSET(0)] 
    NOT IN (
        SELECT ARRAY_REVERSE(SPLIT(FileName, '/'))[OFFSET(1)] || '/' || ARRAY_REVERSE(SPLIT(FileName, '/'))[OFFSET(0)] 
        FROM AMH_FZ_FDR_DEV_SIT.event_store_control_table
    );


Recommendation-
SELECT t.folder_name
FROM AMH_FZ_FDR_DEV_SIT.event_store_temp t
LEFT JOIN (
    SELECT ARRAY_REVERSE(SPLIT(FileName, '/'))[OFFSET(1)] || '/' || ARRAY_REVERSE(SPLIT(FileName, '/'))[OFFSET(0)] AS filename_suffix
    FROM AMH_FZ_FDR_DEV_SIT.event_store_control_table
    WHERE FileName IS NULL
) c
ON ARRAY_REVERSE(SPLIT(t.folder_name, '/'))[OFFSET(1)] || '/' || ARRAY_REVERSE(SPLIT(t.folder_name, '/'))[OFFSET(0)] = c.filename_suffix
WHERE c.filename_suffix IS NULL;

-- Query 2
DELETE FROM AMH_FZ_REPORT_MARTS_TABLES_DEV.Contact_Strategy 
WHERE lifecycle_id IN (
    SELECT DISTINCT id.identifier 
    FROM AMH_FZ_FDR_DEV_SIT.cm_event_arrival 
    WHERE updatedTimestamp >= '2025-06-28 22:00:00+00' 
      AND updatedTimestamp < '2025-06-29 22:00:00+00' 
      AND alert = TRUE 
      AND LOWER(cm_event_arrival.id.channelid) = 'transfers'
);

Recommendation -
DELETE FROM AMH_FZ_REPORT_MARTS_TABLES_DEV.Contact_Strategy cs
WHERE EXISTS (
    SELECT id.identifier
    FROM AMH_FZ_FDR_DEV_SIT.cm_event_arrival cea
    WHERE cs.lifecycle_id = cea.id.identifier
      AND cea.updatedTimestamp >= '2025-06-28 22:00:00+00' 
      AND cea.updatedTimestamp < '2025-06-29 22:00:00+00' 
      AND cea.alert = TRUE 
      AND LOWER(cea.id.channelid) = 'transfers'
);
 

---------------------------------------Frequent Failures--------------------------------:
-- Query 1
MERGE `AMH_FZ_REPORT_MARTS_TABLES_DEV.Account_Level` cs
USING (
    SELECT * 
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER (PARTITION BY lifecycle_id ORDER BY event_received_at) AS row_num 
        FROM `AMH_FZ_FDR_DEV_SIT.event_store` 
        WHERE LOWER(payment_message_source) IN ('hk_gbp_mob', 'hk_gbp_web')
          AND LOWER(segment_channel_type) = 'w'
          AND LOWER(fdz_channel) = 'transfers'
          AND LOWER(event_type) = 'transfer_initiation'
          AND (LOWER(entity_type) != 's' OR entity_type IS NULL)
          AND LOWER(payment_revision_code) = 'o'
          AND LOWER(payment_status) IN ('a', 'p')
          AND LOWER(tpp_payee_payer) IN ('e', 'n', 'd')
          OR (LOWER(channel_name) = 'l' AND LOWER(sender_transaction_type) = 'bf')
    ) 
    WHERE row_num = 1
) event_store
ON cs.lifecycle_id = event_store.lifecycle_id
AND cs.report_name = 'Real Time Dashboard'
AND (cs.lob IS NULL OR cs.lob = '')
WHEN MATCHED THEN 
UPDATE SET lob = "GPB";

--Query 2
CALL AMH_FZ_FDR_DEV_SIT.Real_Time_Dashboard_Proc();

----------------------------------------High Volume Scan Jobs------------------------------:
-- Query 1
call AMH_FZ_FDR_DEV_SIT.Payment_MI_Proc()

-- Query 2
call AMH_FZ_FDR_DEV_SIT.Analyst_Action_Report_Proc();

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'terraform-jenkins-usr${PROJECT_ID}.iam') THEN
        CREATE USER "terraform-jenkins-usr${PROJECT_ID}.iam" CREATEDB CREATEROLE;
    END IF;
END
$$;

-- Grant permissions (these are idempotent)
GRANT ALL ON ALL TABLES IN SCHEMA public TO "terraform-jenkins-usr${PROJECT_ID}.iam";
ALTER USER "terraform-jenkins-usr${PROJECT_ID}.iam" CREATEDB CREATEROLE;

-- Check if user exists before creating
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'query-genie${PROJECT_ID}.iam') THEN
        CREATE USER "query-genie${PROJECT_ID}.iam" CREATEDB CREATEROLE;
    END IF;
END
$$;

-- Grant permissions (these are idempotent)
GRANT ALL ON ALL TABLES IN SCHEMA public TO "query-genie${PROJECT_ID}.iam";
ALTER USER "query-genie${PROJECT_ID}.iam" CREATEDB CREATEROLE;

-- Check if user exists before creating
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'gcp.${PROJECT_ID}.devops-team@hsbc.com') THEN
        CREATE USER "gcp.${PROJECT_ID}.devops-team@hsbc.com";
    END IF;
END
$$;

-- Grant permissions (these are idempotent)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "gcp.${PROJECT_ID}.devops-team@hsbc.com";

-- Extensions (these are idempotent)
CREATE EXTENSION IF NOT EXISTS pgaudit;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
