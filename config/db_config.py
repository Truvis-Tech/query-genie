import configparser
import urllib.parse
from google.cloud.sql.connector import Connector
import os
import sqlalchemy


class GoogleCloudSqlUtility:
    def __init__(self):
        self.config_path = os.path.abspath('./config/US/config.ini')
        config = configparser.ConfigParser()
        if not os.path.exists(self.config_path):
            raise FileNotFoundError(f"Config file not found at: {self.config_path}")
        config.read(self.config_path)
        self.section = 'postgres_db'
        self.project_id = config.get(self.section, 'project_id')
        self.region = config.get(self.section, 'region')
        self.instance_name = config.get(self.section, 'instance_name')
        self.database = config.get(self.section, 'database')
        self.iam_user = config.get(self.section, 'iam_user')
        self.schema = config.get(self.section, 'schema')
        self.input_dir = config.get('extraction_utility', 'data_output_directory')
        self.ip_type = "public"  # Use public since private is enabled
        self.instance_connection_name = f"{self.project_id}:{self.region}:{self.instance_name}"

        # Set GOOGLE_APPLICATION_CREDENTIALS from config if not already set
        self.service_account_file = config.get('extraction_utility', 'service_account_file', fallback=None)
        if self.service_account_file and not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
            os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = self.service_account_file
        self.dataset_id = config.get('extraction_utility', 'dataset_id', fallback=None)
        self.bq_location = config.get('extraction_utility', 'bq_location', fallback='us-central1')

    def get_db_connection(self):
        try:
            connector = Connector()
            conn = connector.connect(
                self.instance_connection_name,
                "pg8000",
                user=self.iam_user,
                db=self.database,
                enable_iam_auth=True,
                ip_type=self.ip_type,
            )
            return conn, connector
        except Exception as e:
            print(f"Error: Unable to connect to the database. {e}")
        return None, None

    def execute_query(self, query, params=None, fetch=False):
        conn, connector = self.get_db_connection()
        if not conn:
            return None
        try:
            cursor = conn.cursor()
            cursor.execute(query, params or ())
            if fetch:
                result = cursor.fetchall()
            else:
                result = None
            conn.commit()
            cursor.close()
            return result
        except Exception as e:
            print(f"Error executing query: {e}")
            return None
        finally:
            conn.close()
            connector.close()

    def insert(self, query, params=None):
        return self.execute_query(query, params)

    def select(self, query, params=None):
        return self.execute_query(query, params, fetch=True)

    def update(self, query, params=None):
        return self.execute_query(query, params)

    def delete(self, query, params=None):
        return self.execute_query(query, params)


# Read and execute SQL file
def execute_sql(self,sql_query):
    
    try:
        self.cursor.execute(sql_query)
    except Exception as e:
        print(f"Error executing Query {sql_query}")

