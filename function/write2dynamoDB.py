import boto3
import json
import datetime

now = datetime.datetime.now()
s3res = boto3.resource('s3')
ec2client = boto3.client('ec2')
asgclient = boto3.client('autoscaling')
dynamores = boto3.resource('dynamodb')
current_month = str(now.month)
current_day = str(now.day)
aws_region = 'us-east-1'


def get_account_ec2_list():
    construct_ec2_list = []
    all_account_ec2 = ec2client.describe_instances(Filters=[{'Name':'tag:Service','Values':['account']},{'Name':'tag:Env','Values':['production']}])
    list_account_ec2 = all_account_ec2['Reservations']
    for each_account_ec2 in list_account_ec2:
        account_ec2 = each_account_ec2['Instances']
        #print(account_ec2)
        enum_account_ec2 = list(enumerate(account_ec2))
        #print(enum_account_ec2)
        for index, each_account_ec2_id in enum_account_ec2:
            #print(each_account_ec2_id)
            ec2_id = each_account_ec2_id['InstanceId']
            ec2_name = next(item for item in each_account_ec2_id['Tags'] if item['Key'] == 'Name')
            #print(ec2_name['Value'])
            construct_ec2_dict = {}
            construct_ec2_dict['id'] = ec2_id
            construct_ec2_dict['name'] = ec2_name['Value']
            construct_ec2_dict['resource'] = 'ec2'
            #print(construct_ec2_dict)
            construct_ec2_list.append(construct_ec2_dict)
            #print(construct_ec2_list)
    #print(construct_ec2_list)
    return construct_ec2_list
    
def get_account_asg_list():
    #Compose a list of resource id from AccountPF tagging
    #Search resource id from Production tagging
    #Evaluate if production resource id is in AccountPF tagging list
    #If yes, then the ASG is belong to Prod and AccountPF
    construct_asg_list = []
    construct_asg_list_service = []
    construct_asg_list_env = []
    all_account_asg_service = asgclient.describe_tags(Filters = [{'Name':'key','Values': ['Service']},{'Name':'value','Values': ['account']}])
    list_account_asg_service = all_account_asg_service['Tags']
    #print(list_account_asg_service)
    enum_list_account_asg_service = list(enumerate(list_account_asg_service))
    #print(enum_list_account_asg_service)
    for index, each_account_asg_service in enum_list_account_asg_service:
        # print(each_account_asg_service)
        resource_id = each_account_asg_service['ResourceId']
        construct_asg_list_service.append(resource_id)
        #print(construct_asg_list_service)
    all_account_asg_env = asgclient.describe_tags(Filters = [{'Name':'key','Values': ['Env']},{'Name':'value','Values': ['production']}])
    list_account_asg_env = all_account_asg_env['Tags']
    enum_list_account_asg_env = list(enumerate(list_account_asg_env))
    #print(enum_list_account_asg_env)
    for index, each_account_asg_env in enum_list_account_asg_env:
        resource_id_env = each_account_asg_env['ResourceId']
        if resource_id_env in construct_asg_list_service:
            construct_asg_dict = {}
            construct_asg_dict['id'] = resource_id_env
            construct_asg_dict['name'] = resource_id_env
            construct_asg_dict['resource'] = 'asg'
            #print(construct_asg_dict)
            construct_asg_list.append(construct_asg_dict)
    #print(construct_asg_list)
    return construct_asg_list

def put_item_to_table(r):
    table = dynamores.Table('accountPF_prod')
    for each_item in r:
        object_dumps = json.dumps(each_item)
        body = json.loads(object_dumps)
        #print(body)
        table.put_item(Item=body)
            
# def put_list_to_s3(r):
#     #print(r)
#     obj = s3res.Object('limliht-config','config/'+aws_region+'/default_document.json')
#     obj.put(Body=json.dumps(r))
#     return obj

# #read file from s3
# def read_list_from_s3(o):
#     read_data = o.get()['Body'].read()
#     print(read_data)

if __name__ == "__main__":
    # try:
        result_ec2 = get_account_ec2_list()
        result_asg = get_account_asg_list()
        print(result_ec2)
        print(result_asg)
        put_item_to_table(result_ec2)
        put_item_to_table(result_asg)
        #print('done')
    # except:
        # print('error')
