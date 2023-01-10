# TP2 : Appréhender l'environnement Linux

Dans ce TP, on va aborder plusieurs sujets, dans le but principal de se familiariser un peu plus avec l'environnement GNU/Linux.

> Pour rappel, nous étudions et utilisons GNU/Linux de l'angle de l'administrateur, qui gère des serveurs. Nous n'allons que très peu travailler avec des distributions orientées client. Rocky Linux est parfaitement adapté à cet usage.

Ce que vous faites dans ce TP deviendra peu à peu naturel au fil des cours et de votre utilsation de GNU/Linux.

Comme d'hab rien à savoir par coeur, jouez le jeu, et la plasticité de votre cerveau fera le reste.

Une seule VM Rocky suffit pour ce TP. N'oubliez pas d'ouvrir les ports firewall quand c'est nécessaire. De façon volontaire, je ne le précise pas à chaque fois.  
Ca doit devenir naturel : vous lancez un programme pour écouter sur un port, alors il faut ouvrir ce port.

# Sommaire

- [TP2 : Appréhender l'environnement Linux](#tp2--appréhender-lenvironnement-linux)
- [Sommaire](#sommaire)
  - [Checklist](#checklist)
- [I. Service SSH](#i-service-ssh)
  - [1. Analyse du service](#1-analyse-du-service)
  - [2. Modification du service](#2-modification-du-service)
- [II. Service HTTP](#ii-service-http)
  - [1. Mise en place](#1-mise-en-place)
  - [2. Analyser la conf de NGINX](#2-analyser-la-conf-de-nginx)
  - [3. Déployer un nouveau site web](#3-déployer-un-nouveau-site-web)
- [III. Your own services](#iii-your-own-services)
  - [1. Au cas où vous auriez oublié](#1-au-cas-où-vous-auriez-oublié)
  - [2. Analyse des services existants](#2-analyse-des-services-existants)
  - [3. Création de service](#3-création-de-service)

## Checklist

> Habituez-vous à voir cette petite checklist, elle figurera dans tous les TPs.

A chaque machine déployée, vous **DEVREZ** vérifier la 📝**checklist**📝 :

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux en mode *"permissive"* (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b1-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

![Checklist](./pics/checklist_is_here.jpg)

# I. Service SSH

Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré par défaut, c'est Rocky qui fait ça nativement.

## 1. Analyse du service

On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.

🌞 **S'assurer que le service `sshd` est démarré**
```
[elyter@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-12-09 11:23:10 EST; 12min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 701 (sshd)
      Tasks: 1 (limit: 5712)
     Memory: 5.4M
        CPU: 526ms
     CGroup: /system.slice/sshd.service
             └─701 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Dec 09 11:28:16 localhost.localdomain sshd[1136]: Connection closed by authenticating user elyter 10.37.132.1 port 58190 [preauth]
Dec 09 11:28:17 localhost.localdomain sshd[1139]: Failed password for elyter from 10.37.132.1 port 58191 ssh2
Dec 09 11:28:18 localhost.localdomain sshd[1139]: Failed password for elyter from 10.37.132.1 port 58191 ssh2
Dec 09 11:28:18 localhost.localdomain sshd[1139]: Connection closed by authenticating user elyter 10.37.132.1 port 58191 [preauth]
Dec 09 11:28:21 localhost.localdomain sshd[1142]: Failed password for elyter from 10.37.132.1 port 58192 ssh2
Dec 09 11:28:21 localhost.localdomain sshd[1142]: Failed password for elyter from 10.37.132.1 port 58192 ssh2
Dec 09 11:28:21 localhost.localdomain sshd[1142]: Connection closed by authenticating user elyter 10.37.132.1 port 58192 [preauth]
Dec 09 11:28:24 localhost.localdomain sshd[1144]: Connection closed by authenticating user elyter 10.37.132.1 port 58193 [preauth]
Dec 09 11:32:06 localhost.localdomain sshd[1209]: Accepted password for elyter from 10.37.132.1 port 58243 ssh2
Dec 09 11:32:06 localhost.localdomain sshd[1209]: pam_unix(sshd:session): session opened for user elyter(uid=1000) by (uid=0)
```
🌞 **Analyser les processus liés au service SSH**
```
[elyter@localhost ~]$ ps -ef | grep ssh
root         701       1  0 11:23 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1209     701  0 11:32 ?        00:00:00 sshd: elyter [priv]
elyter      1213    1209  0 11:32 ?        00:00:00 sshd: elyter@pts/0
elyter      1288    1214  0 11:38 pts/0    00:00:00 grep --color=auto ssh
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```
[elyter@localhost ~]$ sudo ss -ltunp | grep ssh
tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=701,fd=3))   
tcp   LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=701,fd=4))   
```

🌞 **Consulter les logs du service SSH**

```
[elyter@localhost log]$ sudo cat secure | grep ssh
Dec  9 10:36:33 localhost sshd[771]: Server listening on 0.0.0.0 port 22.
Dec  9 10:36:33 localhost sshd[771]: Server listening on :: port 22.
Dec  9 10:56:27 localhost sshd[702]: Server listening on 0.0.0.0 port 22.
Dec  9 10:56:27 localhost sshd[702]: Server listening on :: port 22.
Dec  9 11:02:59 localhost sshd[704]: Server listening on 0.0.0.0 port 22.
Dec  9 11:02:59 localhost sshd[704]: Server listening on :: port 22.
Dec  9 11:04:18 localhost sshd[704]: Server listening on 0.0.0.0 port 22.
Dec  9 11:04:18 localhost sshd[704]: Server listening on :: port 22.
Dec  9 11:23:10 localhost sshd[701]: Server listening on 0.0.0.0 port 22.
Dec  9 11:23:10 localhost sshd[701]: Server listening on :: port 22.
Dec  9 11:27:53 localhost sshd[1129]: Connection closed by authenticating user elyter 10.37.132.1 port 58187 [preauth]
Dec  9 11:28:01 localhost sshd[1131]: Connection closed by authenticating user elyter 10.37.132.1 port 58188 [preauth]
Dec  9 11:28:07 localhost sshd[1133]: Invalid user eliott from 10.37.132.1 port 58189
Dec  9 11:28:09 localhost sshd[1133]: Failed none for invalid user eliott from 10.37.132.1 port 58189 ssh2
Dec  9 11:28:09 localhost sshd[1133]: Connection closed by invalid user eliott 10.37.132.1 port 58189 [preauth]
Dec  9 11:28:13 localhost sshd[1136]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=10.37.132.1  user=elyter
Dec  9 11:28:15 localhost sshd[1136]: Failed password for elyter from 10.37.132.1 port 58190 ssh2
Dec  9 11:28:16 localhost sshd[1136]: Connection closed by authenticating user elyter 10.37.132.1 port 58190 [preauth]
Dec  9 11:28:17 localhost sshd[1139]: Failed password for elyter from 10.37.132.1 port 58191 ssh2
Dec  9 11:28:18 localhost sshd[1139]: Failed password for elyter from 10.37.132.1 port 58191 ssh2
Dec  9 11:28:18 localhost sshd[1139]: Connection closed by authenticating user elyter 10.37.132.1 port 58191 [preauth]
Dec  9 11:28:21 localhost sshd[1142]: Failed password for elyter from 10.37.132.1 port 58192 ssh2
Dec  9 11:28:21 localhost sshd[1142]: Failed password for elyter from 10.37.132.1 port 58192 ssh2
Dec  9 11:28:21 localhost sshd[1142]: Connection closed by authenticating user elyter 10.37.132.1 port 58192 [preauth]
Dec  9 11:28:24 localhost sshd[1144]: Connection closed by authenticating user elyter 10.37.132.1 port 58193 [preauth]
Dec  9 11:32:06 localhost sshd[1209]: Accepted password for elyter from 10.37.132.1 port 58243 ssh2
Dec  9 11:32:06 localhost sshd[1209]: pam_unix(sshd:session): session opened for user elyter(uid=1000) by (uid=0)
```

## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative au protocole SSH

🌞 **Identifier le fichier de configuration du serveur SSH**

🌞 **Modifier le fichier de conf**

- exécutez un `echo $RANDOM` pour demander à votre shell de vous fournir un nombre aléatoire
  - simplement pour vous montrer la petite astuce et vous faire manipuler le shell :)
- changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port
  - dans le compte-rendu je veux un `cat` du fichier de conf
  - filtré par un `| grep` pour mettre en évidence la ligne que vous avez modifié
- gérer le firewall
  - fermer l'ancien port
  - ouvrir le nouveau port
  - vérifier avec un `firewall-cmd --list-all` que le port est bien ouvert
    - vous filtrerez la sortie de la commande avec un `| grep TEXTE`

🌞 **Redémarrer le service**

- avec une commande `systemctl restart`

🌞 **Effectuer une connexion SSH sur le nouveau port**

- depuis votre PC
- il faudra utiliser une option à la commande `ssh` pour vous connecter à la VM

> Je vous conseille de remettre le port par défaut une fois que cette partie est terminée.

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées

![Such a hacker](./pics/such_a_hacker.png)

# II. Service HTTP

Dans cette partie, on ne va pas se limiter à un service déjà présent sur la machine : on va ajouter un service à la machine.

On va faire dans le *clasico* et installer un serveur HTTP très réputé : NGINX.  
Un serveur HTTP permet d'héberger des sites web.

Un serveur HTTP (ou "serveur Web") c'est :

- un programme qui écoute sur un port (ouais ça change pas ça)
- il permet d'héberger des sites web
  - un site web c'est un tas de pages html, js, css
  - un site web c'est aussi parfois du code php, python ou autres, qui indiquent comment le site doit se comporter
- il permet à des clients de visiter les sites web hébergés
  - pour ça, il faut un client HTTP (par exemple, un navigateur web)
  - le client peut alors se connecter au port du serveur (connu à l'avance)
  - une fois le tunnel de communication établi, le client effectuera des requêtes HTTP
  - le serveur répondra à l'aide du protocole HTTP

> Une requête HTTP c'est "donne moi tel fichier HTML". Une réponse c'est "voici tel fichier HTML" + le fichier HTML en question.

Ok bon on y va ?

## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**

- je vous laisse faire votre recherche internet
- n'oubliez pas de préciser que c'est pour "Rocky 9"

🌞 **Démarrer le service NGINX**

🌞 **Déterminer sur quel port tourne NGINX**

- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées
- ouvrez le port concerné dans le firewall

> **NB : c'est la dernière fois que je signale explicitement la nécessité d'ouvrir un port dans le firewall.** Vous devrez vous-mêmes y penser lorsque nécessaire. **Toutes les commandes liées au firewall doivent malgré tout figurer dans le compte-rendu.**

🌞 **Déterminer les processus liés à l'exécution de NGINX**

- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées

🌞 **Euh wait**

- y'a un serveur Web qui tourne là ?
- bah... visitez le site web ?
  - ouvrez votre navigateur (sur votre PC) et visitez `http://<IP_VM>:<PORT>`
  - vous pouvez aussi (toujours sur votre PC) utiliser la commande `curl` depuis un terminal pour faire une requête HTTP
- dans le compte-rendu, je veux le `curl` (pas un screen de navigateur)
  - utilisez Git Bash si vous êtes sous Windows (obligatoire)
  - vous utiliserez `| head` après le `curl` pour afficher que certaines des premières lignes
  - vous utiliserez une option à cette commande `head` pour afficher les 7 premières lignes de la sortie du `curl`

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

- faites un `ls -al <PATH_VERS_LE_FICHIER>` pour le compte-rendu

🌞 **Trouver dans le fichier de conf**

- les lignes qui permettent de faire tourner un site web d'accueil (la page moche que vous avez vu avec votre navigateur)
  - ce que vous cherchez, c'est un bloc `server { }` dans le fichier de conf
  - vous ferez un `cat <FICHIER> | grep <TEXTE> -A X` pour me montrer les lignes concernées dans le compte-rendu
    - l'option `-A X` permet d'afficher aussi les `X` lignes après chaque ligne trouvée par `grep`
- une ligne qui parle d'inclure d'autres fichiers de conf
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - bah ouais, on stocke pas toute la conf dans un seul fichier, sinon ça serait le bordel

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

- bon on est pas en cours de design ici, alors on va faire simplissime
- créer un sous-dossier dans `/var/www/`
  - par convention, on stocke les sites web dans `/var/www/`
  - votre dossier doit porter le nom `tp2_linux`
- dans ce dossier `/var/www/tp2_linux`, créez un fichier `index.html`
  - il doit contenir `<h1>MEOW mon premier serveur web</h1>`

🌞 **Adapter la conf NGINX**

- dans le fichier de conf principal
  - vous supprimerez le bloc `server {}` repéré plus tôt pour que NGINX ne serve plus le site par défaut
  - redémarrez NGINX pour que les changements prennent effet
- créez un nouveau fichier de conf
  - il doit être nommé correctement
  - il doit être placé dans le bon dossier
  - c'est quoi un "nom correct" et "le bon dossier" ?
    - bah vous avez repéré dans la partie d'avant les fichiers qui sont inclus par le fichier de conf principal non ?
    - créez votre fichier en conséquence
  - redémarrez NGINX pour que les changements prennent effet
  - le contenu doit être le suivant :

```nginx
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;

  root /var/www/tp2_linux;
}
```

🌞 **Visitez votre super site web**

- toujours avec une commande `curl` depuis votre PC (ou un navigateur)

# III. Your own services

Dans cette partie, on va créer notre propre service :)

HE ! Vous vous souvenez de `netcat` ou `nc` ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

## 1. Au cas où vous auriez oublié

Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre `nc` en main.

➜ Dans la VM

- `nc -l 8888`
  - lance netcat en mode listen
  - il écoute sur le port 8888
  - sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé

➜ Allumez une autre VM vite fait

- `nc <IP_PREMIERE_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens

> Oubliez pas d'ouvrir le port 8888/tcp de la première VM bien sûr :)

## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.

Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.

🌞 **Afficher le fichier de service SSH**

- vous pouvez obtenir son chemin avec un `systemctl status <SERVICE>`
- mettez en évidence la ligne qui commence par `ExecStart=`
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - c'est la ligne qui définit la commande lancée lorsqu'on "start" le service
    - taper `systemctl start <SERVICE>` ou exécuter cette commande à la main, c'est (presque) pareil

🌞 **Afficher le fichier de service NGINX**

- mettez en évidence la ligne qui commence par `ExecStart=`

## 3. Création de service

![Create service](./pics/create_service.png)

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

- son contenu doit être le suivant (nice & easy)

```service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <PORT>
```

> Vous remplacerez `<PORT>` par un numéro de port random obtenu avec la même méthode que précédemment.

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

- la commande c'est `sudo systemctl daemon-reload`

🌞 **Démarrer notre service de ouf**

- avec une commande `systemctl start`

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`
- vérifier que `nc` écoute bien derrière un port avec un `ss`
  - vous filtrerez avec un `| grep` la sortie de la commande pour n'afficher que les lignes intéressantes
- vérifer que juste ça marche en vous connectant au service depuis une autre VM
  - allumez une autre VM vite fait et vous tapez une commande `nc` pour vous connecter à la première

> **Normalement**, dans ce TP, vous vous connectez depuis votre PC avec un `nc` vers la VM, mais bon. Vos supers OS Windows/MacOS chient un peu sur les conventions de réseau, et ça marche pas super super en utilisant un `nc` directement sur votre machine. Donc voilà, allons au plus simple : allumez vite fait une deuxième qui servira de client pour tester la connexion à votre service `tp2_nc`.

➜ Si vous vous connectez avec le client, que vous envoyez éventuellement des messages, et que vous quittez `nc` avec un CTRL+C, alors vous pourrez constater que le service s'est stoppé

- bah oui, c'est le comportement de `nc` ça ! 
- le client se connecte, et quand il se tire, ça ferme `nc` côté serveur aussi
- faut le relancer si vous voulez retester !

🌞 **Les logs de votre service**

- mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !
- `sudo journalctl -xe -u tp2_nc` pour visualiser les logs de votre service
- `sudo journalctl -xe -u tp2_nc -f ` pour visualiser **en temps réel** les logs de votre service
  - `-f` comme follow (on "suit" l'arrivée des logs en temps réel)
- dans le compte-rendu je veux
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique le démarrage du service
  - une commande `journalctl` filtrée avec `grep` qui affiche un message reçu qui a été envoyé par le client
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique l'arrêt du service

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine
  - comme ça, quand un client se co, puis se tire, le service se relancera tout seul
  - ajoutez `Restart=always` dans la section `[Service]` de votre service
  - n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)