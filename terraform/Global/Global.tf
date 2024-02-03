terraform {
    required_providers {
        panos = {
            source  = "paloaltonetworks/panos"
            version = "~> 1.11.0"
        }
    }
}

provider "panos" {
    hostname = var.panos_hostname
    username = var.panos_username
    password = var.panos_password
}

data "panos_ethernet_interface" "e2"{
    name = "ethernet1/2"
}

data "panos_ethernet_interface" "e1"{
    name = "ethernet1/1"
}

data "panos_virtual_router" "vr1" {
    name = "VR-1"
}

resource "panos_layer3_subinterface" "example" {
    parent_interface = "${data.panos_ethernet_interface.e2.name}.2"
    vsys = "vsys1"
    name = "${data.panos_ethernet_interface.e2.name}.2"
    
    tag = 5
    static_ips = ["10.1.1.1/24"]
    comment = "Configured for internal traffic"

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_virtual_router" "vr1" {
  name = "VR-1"
  interfaces = [
    data.panos_ethernet_interface.e1.name,
    data.panos_ethernet_interface.e2.name,
    data.panos_ethernet_interface.e3.name,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "panos_local_user_db_user" "one" {
    name = "VPN-User"
    password = "password"
    disabled = false

    lifecycle {
        create_before_destroy = true
    }
}

resource "panos_local_user_db_group" "example" {
    name = "VPN-Group"
    users = [
        panos_local_user_db_user.one.name,
    ]

    lifecycle {
        create_before_destroy = true
    }
}