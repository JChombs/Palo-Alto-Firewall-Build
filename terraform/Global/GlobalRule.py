from panos import base
from panos import firewall
from panos import panorama
from panos import objects
from panos import network
from panos import device
from panos import plugins
from panos.policies import Rulebase, SecurityRule, PreRulebase, NatRule, PostRulebase
from panos.objects import AddressObject, CustomUrlCategory
from panos.network import Zone, EthernetInterface, VirtualRouter, ManagementProfile
from config import API, FIREWALL_IP, USERNAME, PASSWORD, HOSTNAME, SERIAL, PYTHON_SCRIPT_STEP3, SCRIPT_PATH, TERRAFORM_SCRIPT_DIRECTORY, GLOB, GLOB_RULE

api = API
firewall_ip = FIREWALL_IP
username = USERNAME
password = PASSWORD
hostnamed = HOSTNAME
seriall = SERIAL

fw = firewall.Firewall(firewall_ip, api_username=username, api_password=password,  version='10.0')
print(fw)

##STEP 3
## Incase we have to just add in default
default = 'default'

## ZONES
TrustZone = 'users'
UntrustZone = 'internet'
dmzzone = 'dmz'


## IP ADDRESSES
hostIP = '192.168.1.20/24'
dmzIP = '192.168.50.10/24'
networkIP = '192.168.1.0/24'
firewallIP = '192.168.1.254/24'
VirtualIP = "192.168.1.10/24"

appsToBlock= ['facebook', 'twitter', 'youtube', 'reddit']
url_categories = ['web-advertisements', 'phishing', 'malware', 'unknown']
allowedApplications = ["ssh", "ssl", "web-browsing", "ftp", "ping"]

## Data filtering object name
theFilter = 'Filter'

## NAT rule name
NatRuleName = "internal internet access"
 
## Name of File blocking security profile
FileBlockName = "PE and Multi blocking"

## WildFire name
WildfireName = "WildinFire"

## URL filtering profile names
urlf1 = "Tier-1"
urlf2 = "Tier-2"
urlf3 = "Tier-3"

## Anti Virus profile
AntiVirusName = "Anti-HTTP"

sourceAddresses = ["192.168.1.20/24", "192.168.1.254/24", "192.168.50.10/24"]
bothhosts = ["192.168.1.20/24", "192.168.1.254/24"]

RuleList = []

rulebase = Rulebase()
fw.add(rulebase)

def RuelBuiler(RuleList):
    for stuff in RuleList:
        rulebase.add(stuff)
        stuff.create()


GPrule1 = SecurityRule(
    name = "httpsToPortal",
    description = "allow https access to portal",
    fromzone = [UntrustZone],
    source = ["any"],
    tozone = [UntrustZone],
    destination = ["172.16.5.200/24"],
    application = ['ssl', 'web-browsing'],
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    url_filtering = 'default',
    action = "allow"
)

RuleList.append(GPrule1)

GPrule2 = SecurityRule(
    name ="FwToLDAP",
    description = "Allow firewall to access LDAP",
    fromzone = [UntrustZone],
    source =['203.0.113.20/24'],
    tozone = [dmzzone],
    destination = ['192.168.50.89/24'],
    application = ['ldap'],
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    url_filtering = 'default',
    action = 'allow'
)

RuleList.append(GPrule2)

GPrule3 = SecurityRule(
    name = "VPN-To-Inside",
    description = "allow outside access to inside",
    fromzone = ["Global-P"],
    source = ["172.16.5.200/24"],
    tozone = [TrustZone],
    destination = ['any'],
    application = ['ssl', 'ssh', 'web-browsing'],
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    url_filtering = 'default',
    action = 'allow'
)

RuleList.append(GPrule3)


RuelBuiler(RuleList)
fw.commit(sync=True)

print('All rules have been successfully implimented, onto the next task...')