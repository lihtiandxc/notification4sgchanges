from datetime import datetime
import boto3
import json
import os

###-------Global Var can be defined in Lambda global var and import with os.environ() method
#str_asg_name = 'limliht-asg,limliht2-asg' #simulate global var in lambda
#global_asg_name = str_asg_name.split(',')
service_tag_name = 'Service'
service_tag = 'account'
env_tag_name = 'Env'
env_tag = 'Production'
#country_tag_name = 'Country'
#country_tag_value = 'US'
accountpf_sg_list = os.environ['global_accountpf_sg_list'].split(',')
#accountpf_sg_list = ['sg-c87e38b8','sg-a8bb07d3','sg-233f485c','sg-2b7b3d5b','sg-0297c272','sg-e29dc892','sg-dcf86ca8']
sns_topic_arn = os.environ['global_sns_topic_arn']

###-------Initialize the boto3 sdk
ec2_resource = boto3.resource('ec2')
sns_client = boto3.client('sns')

###-------
def get_instance_id(network_id):
    
    network_interface = ec2_resource.NetworkInterface(network_id)
    instance_id = network_interface.attachment['InstanceId']
    result = instance_id
    return result
    
###-------    
def get_instance_tag(ec2_id):
    
    instance = ec2_resource.Instance(ec2_id)
    tagging = instance.tags
    
#    for country_value in tagging:
#        if country_value['Key'] == country_tag_name and country_value['Value'] == country_tag_value:
    for env_value in tagging:
        if env_value['Key'] == env_tag_name and env_value['Value'] == env_tag:
            for service_value in tagging:
                if service_value['Key'] == service_tag_name \
                and service_value['Value'] == service_tag :
                    for name_value in tagging:
                        if name_value['Key'] == 'Name':
                            name_ec2 = name_value['Value']
                            print('Located')
                            get_instance_tag_result = service_value['Value'].upper() + ' platform EC2' + \
                            ' with instance id "' +  ec2_id + '" and Instance name "' + name_ec2 + '"'
                            print(get_instance_tag_result)
                            return get_instance_tag_result
                        else:
                            pass
                else:
                    pass
        else:
            pass
#        else:
#            pass

###-------                    
def sns_result(e, ec2_details, network_id):

    #Accessing the value of "e" cloudtrail event    
    details = e['detail']['eventName']
    accesskey_id =  e['detail']['userIdentity']['accessKeyId']
    username = e['detail']['userIdentity']['userName']
    event_id = e['detail']['eventID']
    aws_region = e['detail']['awsRegion']
    source_ip =  e['detail']['sourceIPAddress']
    user_agent = e['detail']['userAgent']
    parameters = e['detail']['requestParameters']['groupSet']['items']
    # The iteration method below help to access value of the list
    sg_parameters_list = [i['groupId'] for i in parameters if 'groupId' in i]
    sg_parameters = json.dumps(sg_parameters_list)
    
    #Looking for illegal securty group
    illegal_sg = []
    for sg in sg_parameters_list:
        if sg not in accountpf_sg_list:
            illegal_sg.append(sg)
    
    #Accessing element time from Event has retuned key error
    #Solution, transform the Event json to String and re-transform back to json
    str_e = json.dumps(e)
    str_e_data = json.loads(str_e)
    event_time_json = str_e_data['detail']['eventTime']
    #Transform the JSON time format to datetime format
    event_time_datetime_format = str(datetime.strptime(event_time_json, '%Y-%m-%dT%H:%M:%SZ'))
    
    #Constructing message for SNS    
    construct_msg = 'Event summary: \
    \n\nEvent name : ' + details + \
    '\nEvent Id : ' + event_id + \
    '\nEvent time (UTC) : ' + event_time_datetime_format + \
    '\nUser Access Key : ' + accesskey_id + \
    '\nUsername : ' + username + \
    '\nAWS Region : ' + aws_region + \
    '\nSource IP : ' + source_ip + \
    '\nAll Security Group attached on this instance : ' + sg_parameters + \
    '\nNon Account Security Group attached on this instance : ' + json.dumps(illegal_sg) + \
    '\n\n\n' + 'Raw event: ' + \
    '\n\n' + str_e

    #Publish SNS topic
    #if details == 'ModifyNetworkInterfaceAttribute':
    event_json = json.dumps(e)
    sns_client.publish(TargetArn = sns_topic_arn, MessageStructure = 'string', \
    Message = construct_msg, Subject = ec2_details)
    #else:
    #    pass

###-------Main function
def lambda_handler(event, context):
    # TODO implement
    event_name = event['detail']['eventName']
    event_network_id = event['detail']['requestParameters']['networkInterfaceId']
    print(event_network_id)
 
    try:
        if event_name == 'ModifyNetworkInterfaceAttribute':
            returned_instance_id = get_instance_id(event_network_id)
        else:
            print('Event not found')
            raise SystemExit()
    except:
        print('Error : Network Interface not found')
        raise SystemExit()
        
    returned_instance_tag = get_instance_tag(returned_instance_id)
    if returned_instance_tag is not None:
        sns_result(event, returned_instance_tag, event_network_id)
    
    return 'Success!'
