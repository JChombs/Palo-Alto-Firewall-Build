## CREATED BY JONAH CAHMEBRS
from config import API, FIREWALL_IP, USERNAME, PASSWORD, HOSTNAME, SERIAL, PYTHON_SCRIPT_STEP3, SCRIPT_PATH, TERRAFORM_SCRIPT_DIRECTORY, GLOB, GLOB_RULE
import os
import time
import subprocess
from panos import firewall


api = API
firewall_ip = FIREWALL_IP
username = USERNAME
password = PASSWORD
hostnamed = HOSTNAME
seriall = SERIAL

fw = firewall.Firewall(firewall_ip, api_username=username, api_password=password,  version='10.0')

pythonScriptStep3 =PYTHON_SCRIPT_STEP3
ScriptPath = SCRIPT_PATH
terraform_script_directory = TERRAFORM_SCRIPT_DIRECTORY
Glob = GLOB
Globrule = GLOB_RULE

def Func1():
    os.chdir(terraform_script_directory)
    os.system('terraform init')
    os.system('terraform validate')
    var = input('Are we destroying or applying?: ')

    if var == 'apply':
        os.system('terraform apply')
    if var == 'destroy':
        os.system('terraform destroy')
    else:
        print('Syntax invalid')

def Func2():
    subprocess.run(["python", pythonScriptStep3], check=True)
    
def Func3():
    os.chdir(Glob)
    os.system('terraform init')
    os.system('terraform validate')
    var = input('Are we destroying or applying?: ')

    if var == 'apply':
        os.system('terraform apply')
    if var == 'destroy':
        os.system('terraform destroy')
    else:
        print('Syntax invalid')
    
    print('now setting up rules')
    subprocess.run(["python", Globrule], check=True)
    
    

print('Configuring Palo Alto Firewall')
time.sleep(2)

print('Here are the options to which steps to run for the Cpastone:')
print('\t1: Step2 ')
print('\t2: Step3 ')
print('\trunnit: run the whole config')

choices = input(str('enter which option you would like to perform or type "Runnit" to do a full configuration: '))

if choices == '1':
    Func1()
    fw = firewall.Firewall(firewall_ip, api_username=username, api_password=password,  version='10.0')
    fw.commit(sync=True)
    print('Step 2 has been completed')
        
if choices == '2':
    Func2()
    print('Step 3 has been completed')
    
if choices == 'runnit':
    Func1()
    print('Networking and objects created, moving on to configuring policies')
    Func2()
    print('now setting some of Global Protect')
    Func3()
    print('Configuration complete')