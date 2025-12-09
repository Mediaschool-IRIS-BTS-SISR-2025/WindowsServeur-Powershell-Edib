# 🛡️ windows-server-automation

Ce dépôt contient un ensemble de scripts PowerShell permettant de déployer et de configurer automatiquement une infrastructure d'entreprise simulée sous Windows Server 2022.

Le projet automatise la création d'un **Contrôleur de Domaine**, d'un **Serveur de Fichiers**, ainsi que des services **DHCP, GPO, FSRM, WSUS et WDS**.

## 🏗️ Architecture du Labo

L'infrastructure repose sur deux machines virtuelles interconnectées en réseau privé.

| Machine | Hostname | IP | Rôles & Services configurés |
| :--- | :--- | :--- | :--- |
| **Serveur 1** | `SRV-DC1` | `192.168.100.10` | AD DS (Contrôleur de Domaine), DNS, DHCP, GPO |
| **Serveur 2** | `SRV-FS1` | `192.168.100.20` | Serveur de Fichiers, Quotas FSRM, WSUS, WDS |
| **Domaine** | `mediaschool.local` | - | Domaine Active Directory |

> **Note Réseau :** Les machines virtuelles sont configurées en **Réseau Interne** (*Internal Network*) nommé `intnet` pour communiquer entre elles de manière isolée.

---

## 🚀 Installation et Utilisation

### Prérequis
* 2 Machines Virtuelles avec **Windows Server 2022** (ou 2019).
* Exécution de tous les scripts en tant qu'**Administrateur**.
* Configuration des IP statiques effectuée manuellement avant le lancement.

### 1️⃣ Partie 1 : Contrôleur de Domaine (SRV-DC1)
*Dossier : `01-Domain-Controller`*

Exécutez les scripts dans cet ordre précis :

1.  **`00-Bootstrap.ps1`** : Renommage du serveur et configuration initiale.
2.  **`01-Install-ADDS.ps1`** : Installation des services AD DS et promotion en Contrôleur de Domaine.
3.  **`02-Config-AD-Structure.ps1`** : Création de l'arborescence (OUs : ECOLE, Administration, Profs, Eleves) et des utilisateurs.
4.  **`03-Config-DHCP.ps1`** : Installation et configuration de l'étendue DHCP.
5.  **`04-Deploy-GPO.ps1`** : Création et liaison des stratégies de groupe (GPO).
6.  **`05-Set-LogonHours.ps1`** : Restriction des horaires de connexion pour les utilisateurs.

> **Configuration Manuelle (GUI) :** Le mappage du lecteur réseau `H:` (Espace Personnel) se configure via la console GPMC (Préférences > Mappages de lecteurs) une fois les scripts terminés.

### 2️⃣ Partie 2 : Serveur de Fichiers & Services (SRV-FS1)
*Dossier : `02-File-Server`*

**Avant de commencer :** Assurez-vous que le DNS de cette machine pointe vers `192.168.100.10`.

1.  **`00-Join-Domain.ps1`** : Jonction du serveur au domaine `mediaschool.local` (Redémarrage requis).
2.  **`01-Install-Roles.ps1`** : Installation des rôles de base (Serveur de fichiers).
3.  **`02-Config-FSRM.ps1`** :
    * Installation du gestionnaire de ressources (FSRM).
    * Création de l'arborescence (`C:\Donnees`).
    * Application d'un quota strict de **100 Mo** pour les dossiers élèves.
4.  **`03-Config-WSUS.ps1`** :
    * Installation et configuration de WSUS (Mises à jour Windows).
    * Stockage configuré sur `C:\WSUS`.
    * Création des groupes cibles (Pilote / Production).
5.  **`04-Config-WDS-MDT.ps1`** :
    * Installation et initialisation de WDS (Déploiement Windows).
    * Configuration du dossier `C:\RemoteInstall`.

---

## 🛠️ Spécificités Techniques & Choix d'Implémentation

* **Adaptation Stockage (C: vs D:) :**
    * Les scripts ont été adaptés pour utiliser le disque système `C:` (ex: `C:\RemoteInstall`, `C:\WSUS`) car le lecteur `D:` est réservé au lecteur CD virtuel dans cet environnement de labo.
* **Intégration MDT :**
    * Le script `04` prépare le socle WDS. L'installation de **MDT (Microsoft Deployment Toolkit)** et de l'**ADK** doit être effectuée manuellement (fichiers `.msi` externes) pour finaliser la chaîne de déploiement.
* **Sécurité des Lecteurs Réseaux :**
    * Pour le mappage automatique du lecteur `H:`, l'option *"Exécuter dans le contexte de sécurité de l'utilisateur connecté"* a été activée dans les GPO pour garantir les droits d'accès NTFS corrects.

## 📝 Auteur

Projet réalisé dans le cadre d'un TP d'administration système et réseau.
Scripts PowerShell développés et validés sous Windows Server 2022.
