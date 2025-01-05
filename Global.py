from panos import base
from panos import firewall
from panos import panorama
from panos import objects
from panos import network
from panos import device
from panos import plugins
from panos.policies import Rulebase, SecurityRule, PreRulebase, NatRule, PostRulebase
from panos.objects import AddressObject, CustomUrlCategory
from panos.network import Zone, EthernetInterface, VirtualRouter, ManagementProfile, IpsecTunnel, IpsecTunnelIpv4ProxyId
from config import URLAPI, USER, API, PASS, HOST, SER, PORT

URLapi = URLAPI
api = API
firewall_ip = '192.168.1.254'
username = USER
password = PASS
hostnamed = HOST
seriall = SER
port = PORT

fw = firewall.Firewall(firewall_ip, api_username=username, api_password=password,  version='10.0')
print(fw)

MyGlobal = IpsecTunnel(
    name = port,
    tunnel_interface = 'tunnel.5',
    type = "global-protect-satellite"
)