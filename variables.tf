variable "rg_name" {
  type = string
  description = "name of the resource group"
  default = "tim_rg"
}

variable "vnet_name" {
  type = string
  description = "name of the virtual network"
  default = "tims_vnet"
}

variable "subnet_name" {
  type = string
  description = "name of the subnet"
  default = "public_sub"
}

variable "public_ip1" {
  type = string
  description = "name of the first public Ip address for the linux virtual machine"
  default = "linux_public_ip1"
}

variable "linux_public_ip2" {
  type = string
  description = "name of the second public Ip address for the linux virtual machine"
  default = "linux_public_ip2"
}

variable "vm_nic1" {
  type = string
  description = "name of the first NIC for the linux virtual machine"
  default = "vm1_nic"
}

variable "vm_nic2" {
  type = string
  description = "name of the second NIC for the linux virtual machine"
  default = "vm2_nic"
}

variable "vm1_name" {
  type = string
  description = "name of the first linux virtual machine"
  default = "linux-vm1"
}

variable "vm2_name" {
  type = string
  description = "name of the second linux virtual machine"
  default = "linux-vm2"
}

variable "heading_one" {
  type = string
  description = "heading one title for index.html"
  default = <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>My Load Balanced Website</title>
</head>
<body>
  <h1 id="dynamicHeading"></h1>
  <script>
    // JavaScript code to detect and display the host dynamically
    var hostname = window.location.hostname;
    document.getElementById("dynamicHeading").innerHTML = "Welcome to the Website Hosted on: " + hostname;
  </script>
</body>
</html>
EOF
}
