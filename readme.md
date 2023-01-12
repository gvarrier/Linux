# Projet Linux fin de module Gael Varrier

Nous allons créer un site WordPress hautement disponible en utilisant des scripts Ansible et Terraform. Avec Terraform, nous aurons des fichiers pour les fournisseurs, les variables et le script principal, ainsi qu'un dossier pour les modèles. Avec Ansible, nous aurons un fichier de playbooks, un dossier de modèles et des fichiers de modèles pour différents éléments tels que HAProxy, Nginx et Docker Compose. Nous allons utiliser Terraform pour définir les variables pour les instances et les réseaux, et créer des instances pour le côté front et back (avec HAProxy et NDS server pour le front, et des instances de GRA et SBG pour le back). Nous utiliserons Ansible pour configurer les instances en utilisant les playbooks et les modèles.

Ansible : 

- fichier playbooks.yml liste toutes les actions à éxécuter 

Voici tous les templates :
- dossier template 
- fichier default.j2 
- fichier haproxy.cfg.j2 
- fichier index.html.j2 
- fichier exports.j2 
- fichier docker-compose.yml.j2 
- dossier ifconfig.io 

Terraform : 

- fichier providers.tf dedans il y a tous les providers, ils permettent de communiquer avec les différents services
- fichier variables.tf on y retrouve les variables utilisées dans le projet
- fichier de script principal
- dossier template

#### Instances

Cette partie comprend on a le côté frontend et backend

1. Front avec installation de HAproxy et NFS server

2. Backend qui contient contient 3 instances dans chaque régions à savoir GRA ET SBG
