from datetime import datetime
import boto3
import json
import os

sns_client = boto3.client('sns')

###-------Global Var can be defined in Lambda global var and import with os.environ() method
#str_asg_name = 'limliht-asg,limliht2-asg' #simulate global var in lambda
#global_asg_name = str_asg_name.split(',')

#accountpf_sg_list = ['sg-c87e38b8','sg-a8bb07d3','sg-233f485c','sg-2b7b3d5b','sg-0297c272','sg-e29dc892','sg-dcf86ca8']
#accountpf_sg_list = ['sg-fbde2f8c','sg-9ba7c2ec','sg-352d1542']
accountpf_sg_list = os.environ['global_accountpf_sg_list'].split(',')
#accountpf_sg_list = accountpf_sg_list.split(',')
accountpf_sg_name = os.environ['global_accountpf_sg_name'].split(',')
#accountpf_sg_name = accountpf_sg_name.split(',')
sns_topic_arn = os.environ['global_sns_topic_arn']
#accountpf_sg_name = ['Prod_sg_mante','Monitor','Stag_account']
combine_sg_list = dict(zip(accountpf_sg_name,accountpf_sg_list)) #why not using dict instead? This design is to fit AWS lambda global var input
#sns_topic_arn = 'arn:aws:sns:us-east-1:751611215147:limliht_topic2'

def construct_sns_msg(e):
    
    request_parameters = e['requestParameters']
    group_id = request_parameters['groupId']
    accesskey_id = e['userIdentity']['accessKeyId']
    username = e['userIdentity']['userName']
    event_name = e['eventName']
    if event_name != 'DeleteSecurityGroup':
        ip_permissions = request_parameters['ipPermissions']
        ip_permissions_item = json.dumps(ip_permissions['items'])
    else:
        ip_permissions_item = 'Security Group has deleted'
    aws_region = e['awsRegion']
    source_ip = e['sourceIPAddress']
    event_id = e['eventID']
    
    str_e = json.dumps(e)
    str_e_data = json.loads(str_e)
    event_time_json = str_e_data['eventTime']
    #Transform the JSON time format to datetime format
    event_time_datetime_format = str(datetime.strptime(event_time_json, '%Y-%m-%dT%H:%M:%SZ'))
    
    #Searching group name based on group id
    for sg_name, sg_id in combine_sg_list.items():
        if sg_id == group_id:
            group_name = sg_name
            #return sg_name
    
    body_msg = 'Event summary: \
    \n\nEvent name : ' + event_name + \
    '\nSecurity Group Name : ' + group_name + \
    '\nSecurity Group ID : ' + group_id + \
    '\nChange Items : ' + ip_permissions_item + \
    '\nEvent Id : ' + event_id + \
    '\nEvent time (UTC) : ' + event_time_datetime_format + \
    '\nUser Access Key : ' + accesskey_id + \
    '\nUsername : ' + username + \
    '\nAWS Region : ' + aws_region + \
    '\nSource IP : ' + source_ip + \
    '\n\n\n' + 'Raw event: ' + \
    '\n\n' + str_e 
    
    subject_msg = 'Account Platform Security Group ({}) Rules Changes'.format(group_id)
    trigger_notification(body_msg, subject_msg)

def trigger_notification(event_detail, subject):
    
    sns_client.publish(TargetArn = sns_topic_arn, MessageStructure = 'string', \
    Message = event_detail, Subject = subject)

    
def lambda_handler(event, context):
    # TODO implement
    print(event)
    if (event['detail']['eventName'] == 'AuthorizeSecurityGroupIngress' or \
    'AuthorizeSecurityGroupEgress' or 'RevokeSecurityGroupEgress' or \
    'RevokeSecurityGroupIngress') or 'DeleteSecurityGroup' and \
    event['detail']['requestParameters'] \
    ['groupId'] in accountpf_sg_list:
        construct_sns_msg(event['detail'])
    
    return 'Success'
