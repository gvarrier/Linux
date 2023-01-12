# Création d'une ressource de paire de clés SSH
resource "openstack_compute_keypair_v2" "keypair_gra" {
  provider   = openstack.ovh
  name       = "sshkey_eductive26_gra"
  public_key = file("~/.ssh/id_rsa.pub")
  region     = element(var.regions, 0)
}
# Création d'une ressource de paire de clés SSH
resource "openstack_compute_keypair_v2" "keypair_sbg" {
  provider   = openstack.ovh
  name       = "sshkey_eductive26_sbg"
  public_key = file("~/.ssh/id_rsa.pub")
  region     = element(var.regions, 1)
}
# Création d'un réseau privé
 resource "ovh_cloud_project_network_private" "private_net" {
    name         = "private_network_${var.instance_name}"   # Nom du réseau
    service_name = var.service_name
    regions      = var.regions
    provider     = ovh.ovh                                  # Nom du fournisseur
    vlan_id      = var.vlan_id                              # Identifiant du vlan pour le vRrack
 }
resource "ovh_cloud_project_network_private_subnet" "subnet_gra" {
    service_name = var.service_name
    network_id   = ovh_cloud_project_network_private.private_net.id
    start        = var.vlan_dhcp_start                          # Première IP du sous réseau
    end          = var.vlan_dhcp_end                            # Dernière IP du sous réseau
    network      = var.vlan_dhcp_network
    region       = element(var.regions,0)
    provider     = ovh.ovh                                      # Nom du fournisseur
    no_gateway   = true                                         # Pas de gateway par defaut
}
resource "ovh_cloud_project_network_private_subnet" "subnet_sbg" {
    service_name = var.service_name
    network_id   = ovh_cloud_project_network_private.private_net.id
    start        = var.vlan_dhcp_start                          # Première IP du sous réseau
    end          = var.vlan_dhcp_end                            # Dernière IP du sous réseau
    network      = var.vlan_dhcp_network
    region       = element(var.regions,1)
    provider     = ovh.ovh                                      # Nom du fournisseur
    no_gateway   = true                                         # Pas de gateway par defaut
}

# Création d'une instance backend gra
resource "openstack_compute_instance_v2" "instance_backend_gra" {
  name        = "backend_eductive${var.vlan_id}_${element(var.regions, 0)}_${count.index+1}"    # Nom de l'instance
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = element(var.regions,0)           # Nom de la régions
  count       = var.nbr_backend
  # Nom de la ressource openstack_compute_keypair_v2 nommée test_keypair
  key_pair    = openstack_compute_keypair_v2.keypair_gra.name
# Composant réseau par défaut
  network {
    name      = "Ext-Net"
  }
  network {
    name = ovh_cloud_project_network_private.private_net.name
    fixed_ip_v4 = "192.168.${var.vlan_id}.${count.index+1}"
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet_gra]
}
# Création d'une instance backend sbg
resource "openstack_compute_instance_v2" "instance_backend_sbg" {
  name        = "backend_eductive${var.vlan_id}_${element(var.regions, 1)}_${count.index+1}"    # Nom de l'instance
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = element(var.regions,1)           # Nom de la régions
  count       = var.nbr_backend
  # Nom de la ressource openstack_compute_keypair_v2 nommée test_keypair
  key_pair    = openstack_compute_keypair_v2.keypair_sbg.name
 #Composant réseau par défaut
  network {
    name      = "Ext-Net"
  }
  network {
    name = ovh_cloud_project_network_private.private_net.name
    fixed_ip_v4 = "192.168.${var.vlan_id}.${count.index+10}"
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet_sbg]
}
# Création d'une instance frontend
resource "openstack_compute_instance_v2" "instance_frontend" {
  name        = "frontend_eductive${var.vlan_id}"    # Nom de l'instance
  provider    = openstack.ovh        # Nom du fournisseur
  image_name  = var.image_name       # Nom de l'image
  flavor_name = var.flavor_name      # Nom du type d'instance
  region      = element(var.regions,0)           # Nom de la régions
   # Nom de la ressource openstack_compute_keypair_v2 nommée test_keypair
  key_pair    = openstack_compute_keypair_v2.keypair_gra.name
 #Composant réseau par défautnetwork {
  network {
    name      = "Ext-Net"
  }
  network {
    name = ovh_cloud_project_network_private.private_net.name
    fixed_ip_v4 = "192.168.${var.vlan_id}.254"
  }
  depends_on = [ovh_cloud_project_network_private_subnet.subnet_gra]
}
#BDD
resource "ovh_cloud_project_database" "db_eductive26" {
  engine       = "mysql"
  flavor       = "db1-4"
  
  nodes {
    region = "GRA"
  }
  plan     = "essential"
  version  = "8"
}

resource "ovh_cloud_project_database_user" "eductive26" {
  service_name = ovh_cloud_project_database.db_eductive26.service_name
  engine       = ovh_cloud_project_database.db_eductive26.engine
  name         = "eductive26"
  cluster_id   = ovh_cloud_project_database.db_eductive26.id
}

output "db_username" {
  value = ovh_cloud_project_database_user.eductive26.name
}

output "db_password" {
  value     = "Mot_de_passe"
  sensitive = true
}

resource "ovh_cloud_project_database_database" "database" {
  service_name = ovh_cloud_project_database.db_eductive26.service_name
  cluster_id   = ovh_cloud_project_database.db_eductive26.id
  engine       = ovh_cloud_project_database.db_eductive26.engine
  name         = "wordpress_data"
  
}

resource "ovh_cloud_project_database_ip_restriction" "iprestriction_gra" {
  count        = var.nbr_backend
  service_name = ovh_cloud_project_database.db_eductive26.service_name
  cluster_id   = ovh_cloud_project_database.db_eductive26.id
  engine       = ovh_cloud_project_database.db_eductive26.engine
  ip           = "${openstack_compute_instance_v2.instance_backend_gra[count.index].access_ip_v4}/32"
}

resource "ovh_cloud_project_database_ip_restriction" "iprestriction_sbg" {
  count        = var.nbr_backend
  service_name = ovh_cloud_project_database.db_eductive26.service_name
  cluster_id   = ovh_cloud_project_database.db_eductive26.id
  engine       = ovh_cloud_project_database.db_eductive26.engine
  ip           = "${openstack_compute_instance_v2.instance_backend_sbg[count.index].access_ip_v4}/32"
}
#Ansible
resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml"
  content = templatefile("templates/inventory.tmpl",
    {
      db_name      = ovh_cloud_project_database_database.database.name
      db_hostname  = split("/",split("@",ovh_cloud_project_database.db_eductive26.endpoints[0].uri)[1])[0]
      db_username  = ovh_cloud_project_database_user.eductive26.name
      db_password  = ovh_cloud_project_database_user.eductive26.password
      front        = openstack_compute_instance_v2.instance_frontend.access_ip_v4,
      backends_sbg = [for k, p in openstack_compute_instance_v2.instance_backend_sbg: p.access_ip_v4],
      backends_gra = [for k, p in openstack_compute_instance_v2.instance_backend_gra: p.access_ip_v4],
    }
  )
}
