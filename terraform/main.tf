## CREATED BY JONAH CAHMEBRS AND SPENCER EVANS

terraform {
    required_providers {
        panos = {
            source  = "paloaltonetworks/panos"
            version = "~> 1.11.1"
        }
    }
}

provider "panos" {
    hostname = var.panos_hostname
    username = var.panos_username
    password = var.panos_password
}

variable "panos_hostname" {
  type = string
  default = "192.168.1.254"
}

variable "panos_username" {
  type = string
  default = "admin"
}

variable "panos_password" {
  type = string
  default = "Pal0Alt0!"
}

variable "Omega_list"{
    type = list(string)
    default = [ "abortion", "abused-drugs", "adult", "alcohol-and-tobacco", "artificial-intelligence", "auctions", "business-and-economy", "command-and-control", "computer-and-internet-info",
    "content-delivery-networks", "copyright-infringement", "cryptocurrency", "dating", "dynamic-dns", "educational-institutions", "encrypted-dns", "entertainment-and-arts", "extremism", "financial-services",
    "gambling", "games", "government", "grayware", "hacking", "health-and-medicine", "home-and-garden", "hunting-and-fishing", "insufficient-content", "internet-communications-and-telephony",
    "internet-portals", "job-search", "legal", "malware", "military", "motor-vehicles", "music", "newly-registered-domain", "news", "not-resolved", "nudity", "online-storage-and-backup", "parked",
    "peer-to-peer", "personal-sites-and-blogs", "philosophy-and-political-advocacy", "phishing", "private-ip-addresses", "proxy-avoidance-and-anonymizers", "questionable", "ransomware", "real-estate", 
    "real-time-detection", "recreation-and-hobbies", "reference-and-research", "religion", "scanning-activity", "search-engines", "sex-education", "shareware-and-freeware", "shopping", "social-networking",
    "society", "sports", "stock-advice-and-tools", "streaming-media", "swimsuits-and-intimate-apparel", "training-and-tools", "translation", "travel", "unknown", "weapons", "web-advertisements", 
    "web-based-email", "web-hosting", "medium-risk", "low-risk", "high-risk" ]
}

variable "tier1L" {
    type = list(string)
    default = [ "abortion", "abused-drugs", "adult", "alcohol-and-tobacco", "artificial-intelligence", "auctions", "business-and-economy", "command-and-control", "computer-and-internet-info",
    "content-delivery-networks", "copyright-infringement", "cryptocurrency", "dating", "dynamic-dns", "educational-institutions", "encrypted-dns", "entertainment-and-arts", "extremism",
    "gambling", "games", "grayware", "hacking", "high-risk", "health-and-medicine", "home-and-garden", "hunting-and-fishing", "insufficient-content", "internet-communications-and-telephony",
    "internet-portals", "job-search", "legal", "low-risk", "malware", "medium-risk", "military", "motor-vehicles", "music", "newly-registered-domain", "news", "not-resolved", "nudity", "online-storage-and-backup", "parked",
    "peer-to-peer", "personal-sites-and-blogs", "philosophy-and-political-advocacy", "phishing", "private-ip-addresses", "proxy-avoidance-and-anonymizers", "questionable", "ransomware", "real-estate", 
    "real-time-detection", "recreation-and-hobbies", "religion", "scanning-activity", "sex-education", "shareware-and-freeware", "shopping", "social-networking",
    "society", "sports", "stock-advice-and-tools", "streaming-media", "swimsuits-and-intimate-apparel", "training-and-tools", "translation", "travel", "unknown", "weapons", "web-advertisements", 
    "web-based-email", "web-hosting" ]
}

variable "tier2L" {
    type = list(string)
    default = [ "abortion", "abused-drugs", "adult", "alcohol-and-tobacco", "artificial-intelligence", "auctions", "business-and-economy", "command-and-control", "computer-and-internet-info",
    "content-delivery-networks", "copyright-infringement", "cryptocurrency", "dating", "dynamic-dns", "educational-institutions", "encrypted-dns", "entertainment-and-arts", "extremism", "financial-services",
    "gambling", "games", "government", "grayware", "hacking", "health-and-medicine", "home-and-garden", "hunting-and-fishing", "insufficient-content", "internet-communications-and-telephony",
    "internet-portals", "job-search", "legal", "malware", "military", "motor-vehicles", "music", "newly-registered-domain", "news", "not-resolved", "nudity", "parked",
    "peer-to-peer", "personal-sites-and-blogs", "philosophy-and-political-advocacy", "phishing", "private-ip-addresses", "proxy-avoidance-and-anonymizers", "questionable", "ransomware", "real-estate", 
    "real-time-detection", "recreation-and-hobbies", "reference-and-research", "religion", "scanning-activity", "search-engines", "sex-education", "shareware-and-freeware", "shopping", "social-networking",
    "society", "sports", "stock-advice-and-tools", "streaming-media", "swimsuits-and-intimate-apparel", "training-and-tools", "translation", "travel", "unknown", "weapons", "web-advertisements", 
    "web-based-email", "web-hosting", "medium-risk", "low-risk", "high-risk" ]
}

data "panos_system_info" "x" {}


resource "panos_management_profile" "AllowPing" {
    name = "Allow-Ping"
    ping = true

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_ethernet_interface" "e1" {
  name        = "ethernet1/1"
  mode        = "layer3"
  static_ips  = ["203.0.113.20/24"]
  enable_dhcp = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_ethernet_interface" "e2" {
  name        = "ethernet1/2"
  mode        = "layer3"
  static_ips  = ["192.168.1.1/24"]
  enable_dhcp = false
  management_profile = panos_management_profile.AllowPing.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_ethernet_interface" "e3" {
  name        = "ethernet1/3"
  mode        = "layer3"
  static_ips  = ["192.168.50.1/24"]
  enable_dhcp = false
  lifecycle {
    create_before_destroy = true
  }
}

#Global Protect Step
resource "panos_layer3_subinterface" "example" {
    parent_interface = panos_ethernet_interface.e2.name
    vsys = "vsys1"
    name = "${panos_ethernet_interface.e2.name}.2"
    management_profile = panos_management_profile.AllowPing.name
    static_ips = ["192.168.2.1/24"]
    comment = "Configured for internal traffic"

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_virtual_router" "vr1" {
  name = "VR-1"
  interfaces = [
    panos_ethernet_interface.e1.name,
    panos_ethernet_interface.e2.name,
    panos_ethernet_interface.e3.name,
    panos_layer3_subinterface.example.name,
    panos_tunnel_interface.tunn11.name,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
##CONFIRM WITH SPENCER THESE ARE CORRECT
resource "panos_static_route_ipv4" "defaultroute" {
  name           = "Default-Route"
  virtual_router = panos_virtual_router.vr1.name
  destination    = "0.0.0.0/0"
  interface      = "ethernet1/1"
  next_hop       = "203.0.113.1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_zone" "internet" {
  name = "internet"
  mode = "layer3"
  interfaces = [
    panos_ethernet_interface.e1.name,
  ]
  enable_user_id = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_zone" "users" {
  name = "users"
  mode = "layer3"
  interfaces = [
    panos_ethernet_interface.e2.name,
    panos_layer3_subinterface.example.name,
    panos_tunnel_interface.tunn11.name,
  ]
  enable_user_id = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_zone" "GP" {
  name = "GPzone"
  mode = "layer3"
  interfaces = [
    panos_tunnel_interface.tunn11.name,
  ]
  enable_user_id = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_zone" "dmz" {
  name = "dmz"
  mode = "layer3"
  interfaces = [
    panos_ethernet_interface.e3.name,
  ]
  enable_user_id = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_nat_rule" "example" {
    name = "internal internet access"
    source_zones = [panos_zone.users.name, panos_zone.dmz.name, panos_zone.GP.name]
    destination_zone = panos_zone.internet.name
    to_interface = "any"
    source_addresses = ["any"]
    destination_addresses = ["any"]
    sat_type = "dynamic-ip-and-port"
    sat_address_type = "interface-address"
    sat_interface = panos_ethernet_interface.e1.name
    sat_ip_address = "203.0.113.20/24"

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_file_blocking_security_profile" "MultiPE"{
    name = "PE and Multi blocking"
    description = "block PE file types and any multi-level-encoded files for access between the internet and the 192.168.1.0/24 network segment"
    rule {
        name = "PE"
        applications = ["any"]
        file_types = ["PE"]
        action = "alert"
    }
    rule {
        name = "multi"
        applications = ["any"]
        file_types = ["Multi-Level-Encoding"]
        action = "alert"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_wildfire_analysis_security_profile" "WildinFire" {
    name = "WildinFire"
    description = "enabled on all Security policy rules that allow internet access"
    rule {
        name = "pe"
        applications = ["any"]
        file_types = ["pe"]
        direction = "both"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_url_filtering_security_profile" "tier-1" {
    name = "Tier-1"
    description = "Allow access to only URL categories government, financial-services, reference-and-research, and search-engines"
    ucd_mode = "disabled"
    block_categories = var.tier1L
    allow_categories = ["government", "financial-services", "reference-and-research", "search-engines"]
    ucd_log_severity = "${data.panos_system_info.x.version_major > 8 ? "medium" : var.panos_username}"
    log_container_page_only = true
    log_http_header_xff = true
    log_http_header_referer = true
    log_http_header_user_agent = true

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_url_filtering_security_profile" "tier-2" {
    name = "Tier-2"
    description = "Allow access to only the URL category online-storage-and-backup"
    ucd_mode = "disabled"
    block_categories = var.tier2L
    allow_categories  = ["online-storage-and-backup"]
    ucd_log_severity = "${data.panos_system_info.x.version_major > 8 ? "medium" : var.panos_username}"
    log_container_page_only = true
    log_http_header_xff = true
    log_http_header_referer = true
    log_http_header_user_agent = true

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_url_filtering_security_profile" "tier-3" {
    name = "Tier-3"
    description = "Allow access to all URL categories."
    ucd_mode = "disabled"
    ucd_log_severity = "${data.panos_system_info.x.version_major > 8 ? "medium" : var.panos_username}"
    log_container_page_only = true
    log_http_header_xff = true
    log_http_header_referer = true
    log_http_header_user_agent = true

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_antivirus_security_profile" "Anti-HTTP" {
    name = "Anti-HTTP"
    description = "reset the client and the server when a virus is detected in HTTP traffic"
    decoder {
        name = "http"
        action = "reset-both"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_custom_data_pattern_object" "some_obj" {
    name = "New Object"
    description = "for my data filtering security profile"
    type = "regex"
    regex {
        name = "my regex"
        file_types = ["any"]
        regex = "this is my regex"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_data_filtering_security_profile" "example" {
    name = "Filter"
    description = "a datafitering profile"
    rule {
        data_pattern = panos_custom_data_pattern_object.some_obj.name
        applications = ["any"]
        file_types = ["any"]
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_anti_spyware_security_profile" "Spyware" {
     name = "Spyware"
     description = "use the DNS Sinkhole feature for Palo Alto Networks DNS Signatures and consult a custom External Dynamic List that references Palo Alto standard list."
     sinkhole_ipv4_address = "pan-sinkhole-default-ip"
     rule {
         name = "med-low-info"
         threat_name = "any"
         category = "any"
         action = "alert"
         packet_capture = "disable"
         severities = ["medium", "low", "informational"]
     }

     rule{
        name = "crit-high"
        threat_name = "any"
        category = "any"
        action = "drop"
        packet_capture = "disable"
        severities = ["critical", "high"]
     }

     lifecycle {
         create_before_destroy = true
     }
 }

 resource "panos_edl" "dmz-list" {
    name = "DMZ-list"
    type = "domain"
    description = "list of sinkhole in dmz"
    source = "http://192.168.50.10/dns-sinkhole.txt"
    repeat = "hourly"

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_ldap_profile" "ldap-server" {
    name = "LDAP Server Profile"
    base_dn = "dc=panw,dc=lab"
    bind_dn = "cn=admin,dc=panw,dc=lab"
    password = "Pal0Alt0!"
    ssl = false
    bind_timeout = 30
    search_timeout = 30
    retry_interval = 120
    server {
        name = "ldap.panw.lab"
        server = "192.168.50.89"
        port = 389
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_authentication_profile" "gp_auth" {
    name = "gp-authentication-profile"
    lockout_failed_attempts = "5"
    lockout_time = 4
    allow_list = ["all"]
    type {
      local_database = true

      }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_authentication_profile" "ldap_auth" {
    name = "LDAP-authentication-profile"
    lockout_failed_attempts = "5"
    lockout_time = 4
    allow_list = ["all"]
    type {
      ldap {
        server_profile = "LDAP Server Profile"
      }

      }

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_tunnel_interface" "tunn11" {
    name = "tunnel.11"
    comment = "Configured for internal traffic"

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_nat_rule" "NoNar" {
    name = "gp-portal-no-nat"
    type = "ipv4"
    source_zones = [panos_zone.users.name]
    destination_zone = panos_zone.internet.name
    to_interface = panos_ethernet_interface.e1.name
    source_addresses = ["any"]
    destination_addresses = ["203.0.113.20"]
}

resource "panos_local_user_db_user" "one" {
    name = "AdminBob"
    password = "Pal0Alt0"
    disabled = false

    lifecycle {
        create_before_destroy = true
    }
}