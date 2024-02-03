
## CREATED BY JONAH CAHMEBRS
## WHAT IS PRECONFIGURED FOR THIS MACHINE
# STEP 2
#   all of step 2 is configured

#STEP 3
#   The first 3 bullet points are configured
from config import API, FIREWALL_IP, USERNAME, PASSWORD, HOSTNAME, SERIAL, PYTHON_SCRIPT_STEP3, SCRIPT_PATH, TERRAFORM_SCRIPT_DIRECTORY, GLOB, GLOB_RULE
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

Tier3 = SecurityRule(
    name = 'Tier 3',
    description = 'Security rule for Tier 3 URL filtering',
    fromzone = ["any"],
    source = [hostIP, "172.16.5.200-172.16.5.250"],
    source_user = ["any"],
    tozone = [UntrustZone],
    destination = ["any"],
    action = 'allow',
    url_filtering = urlf3,
    disabled = False,
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    log_end = True
)

RuleList.append(Tier3)

Tier2 = SecurityRule(
    name = 'Tier 2',
    fromzone = dmzzone,
    source = ["any"],
    source_user = ["any"],
    tozone = UntrustZone,
    destination = ["any"],
    application = ["any"],
    action = "allow",
    url_filtering = urlf2,
    disabled = False,
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    log_end = True
)

RuleList.append(Tier2)

Tier1 = SecurityRule(
    name = "Tier 1",
    fromzone = TrustZone,
    source = ["192.168.1.20/24", "172.16.5.200-172.16.5.250"],
    source_user = ["any"],
    negate_source = True,
    tozone = UntrustZone,
    destination = ["any"],
    application = ["any"],
    action = 'allow',
    url_filtering = urlf1,
    disabled = False,
    virus = "default",
    spyware = "default",
    wildfire_analysis = "default",
    vulnerability = "default",
    log_end = True
)

RuleList.append(Tier1)

Internet = SecurityRule(
    name = "Internet Access",
    description = "Internet access for 192.168.1.0 network",
    fromzone=[TrustZone, dmzzone, "GPzone"],
    source= ['any'],
    tozone=[UntrustZone],
    destination='203.0.113.20',
    action='allow',
    url_filtering = default,
    file_blocking = FileBlockName,
    virus = default,
    spyware = "Spyware",
    vulnerability = default,
    wildfire_analysis = WildfireName,
    disabled = False,
    log_end = True,
)

RuleList.append(Internet)

APPrule = SecurityRule(
    name= "Block apps",
    description="Block Facebook, Twitter, YouTube, 2600.org, and Reddit as well as url categories",
    fromzone=[TrustZone, dmzzone],               # Source Zone
    source=["any"],          # Source Address (192.168.1.0/24 network)
    tozone=[UntrustZone],               # Destination Zone
    destination='any',                  # Destination Address (Website address objects)
    application = appsToBlock,
    action="deny",                      # Action (deny the traffic)
    virus = "Anti-HTTP",
    spyware = default,
    vulnerability = default,
    url_filtering =default,
    wildfire_analysis = default,
    disabled = False,
    log_end = True
)

RuleList.append(APPrule)

BlockURL = SecurityRule(
    name = "Block URL",
    description ="Block URL Categoires",
    fromzone=[TrustZone, dmzzone],               # Source Zone
    source=["any"],          # Source Address (192.168.1.0/24 network)
    tozone=[UntrustZone],               # Destination Zone
    destination='any',
    action="deny",                      # Action (deny the traffic)
    virus = default,
    category = url_categories,
    spyware = default,
    vulnerability = default,
    url_filtering =default,
    wildfire_analysis = default,
    disabled = False,
    log_end = True    
)

RuleList.append(BlockURL)

Access2DMZrule = SecurityRule(
    name="Allow Internal to DMZ",
    description="Allow specific applications from 192.168.1.20 and 192.168.1.254 to 192.168.50.10",
    fromzone=[TrustZone],                                                        # Source Zone (e.g., Internal)
    source=[hostIP, firewallIP],                                                    # Source Address (192.168.1.20 and 192.168.1.254)
    tozone=[dmzzone],                                                              # Destination Zone
    application = ['ftp', 'ping', 'ssh', 'ssh-tunnel', 'ssl', 'web-browsing'], # Allowed Applications
    destination=[dmzIP],                                          # Destination Address (192.168.1.10)
    action="allow",# Action (allow the traffic)
    virus = default,
    spyware = default,
    vulnerability = default,
    url_filtering =default,
    wildfire_analysis = default,
    disabled = False,
    log_end = True
)

RuleList.append(Access2DMZrule)

# Sinkhole1 = SecurityRule(
#     name = "Palo-Sinkhole",
#     description = "Sinkhole connected to Palo Alto defualt",
#     fromzone = ['any'],
#     tozone = ["any"],
#     source = ["any"],
#     source_user = ['any'],
#     destination = ['any'],
#     spyware = "Spyware",
#     virus = "default",
#     wildfire_analysis = "default",
#     vulnerability = "default",
#     url_filtering = 'default',
#     action = 'deny',
#     log_end = True
# )

#RuleList.append(Sinkhole1)
RuelBuiler(RuleList)
fw.commit(sync=True)

print('All rules have been successfully implimented, onto the next task...')