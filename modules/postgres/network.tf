resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["${var.vnet_ip_cidr}"]
  location            = "UKSouth"
  resource_group_name = "${var.resource_group_name}"
}
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_ip_cidr}"
  service_endpoints    = ["Microsoft.Sql"]
}
resource "azurerm_postgresql_virtual_network_rule" "test" {
  name                                 = "postgresql-vnet-rule"
  resource_group_name                  = "${var.resource_group_name}"
  server_name                          = "${azurerm_postgresql_server.postgres-server.name}"
  subnet_id                            = "${azurerm_subnet.subnet.id}"
  ignore_missing_vnet_service_endpoint = true
  depends_on = [azurerm_postgresql_database.postgres-db]
}
resource "azurerm_network_security_group" "sg" {
  name                = "nsg"
  location            = "UKSouth"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                        = "allow-ingress"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "${var.office_ip}"
    destination_address_prefix  = "*"
  }
  security_rule {
    name                        = "allow-egress"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "apply-sg-to-vnet" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"
  depends_on = [azurerm_network_security_group.sg, azurerm_virtual_network.vnet]
}
