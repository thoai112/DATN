
# DAG to run the training ECS task using ECSOperator


from http import client
from airflow import DAG
from airflow.contrib.operators.ecs_operator import ECSOperator
from airflow.utils.dates import days_ago
import boto3
import datetime as dt

CLUSTER_NAME = "ml-cluster"  
CONTAINER_NAME = "ecs-ttst-container-1"  
LAUNCH_TYPE = "FARGATE"
SERVICE_NAME = "ecs-ttst-service-1"  

with DAG(
    dag_id = "ecs_fargate_dag_1",
    schedule_interval=None,
    catchup=False,
    start_date=days_ago(1)
) as dag:
    client = boto3.client('ecs', endpoint_url='https://localhost.localstack.cloud:4566', verify=False)
    services=client.list_services(cluster=CLUSTER_NAME,launchType=LAUNCH_TYPE)
    service=client.describe_services(cluster=CLUSTER_NAME,services=services['serviceArns'])
    taskdef=""
    netconfig={}
    for v in service['services']:
        if v['serviceName'] == SERVICE_NAME:
            taskdef=v['taskDefinition']
            netconfig=v['networkConfiguration']
            break
    ecs_operator_task = ECSOperator(
        task_id = "ecs_operator_task",
        dag=dag,
        cluster=CLUSTER_NAME,
        task_definition=taskdef,
        launch_type=LAUNCH_TYPE,
        verify=False,
        overrides={
            "containerOverrides":[
                {
                    "name":CONTAINER_NAME,
                    'memoryReservation': 500
                },
            ],
        },
        network_configuration=netconfig,
        awslogs_group="/train-task-logs",
        awslogs_stream_prefix="ecs",
    )