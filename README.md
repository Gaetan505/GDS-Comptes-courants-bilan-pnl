# Reporting Financier Multinational - Looker Studio & BigQuery

## 📌 Présentation du Projet

Développement d’un système de reporting financier automatisé pour un groupe international, permettant le suivi en temps réel des transactions financières pour les comptes **PNL**, **Bilan**, et **Courants**. Ce projet vise à centraliser les écritures comptables issues de **SAP (BKPF, BSEG)**, les transformer et les visualiser dans des tableaux de bord dynamiques sur **Looker Studio**.



## 🎯 Objectifs et Enjeux

* Optimiser le suivi des comptes financiers dans un environnement multi-filiales.
* Automatiser l’extraction, la transformation et le chargement des données depuis **SAP**.
* Sécuriser l’accès aux données comptables selon le périmètre de chaque utilisateur.
* Fournir une vue claire et interactive des écritures non soldées et des mouvements financiers.



## ⚙️ Architecture Technique

1. **Extraction des données depuis SAP** : Tables **BKPF** et **BSEG** pour récupérer les écritures comptables.
2. **Stockage et traitement dans BigQuery** : Création de tables matérialisées et procédures stockées pour les traitements automatiques.
3. **Mapping des sociétés** : Association des codes SAP (BUKRS) avec les codes de reporting (FRxxx).
4. **Jointures sécurisées** : Fusion des données avec les périmètres utilisateurs pour garantir un accès restreint.
5. **Visualisation dans Looker Studio** : Création de tableaux de bord dynamiques avec filtrage par utilisateur.


## 🚀 Technologies Utilisées

* **Google Cloud Platform (GCP)**
* **BigQuery** pour le traitement des données
* **Looker Studio (ex Data Studio)** pour la visualisation
* **SQL avancé** (Procédures stockées, Data Blending)



## ✅ Fonctionnalités Clés

* **Reporting PNL** : suivi des produits et charges par période sélectionnée.
* **Reporting Bilan** : affichage des pièces non soldées à une date donnée.
* **Reporting Courants** : suivi des flux intra-groupe.
* **Filtrage dynamique par utilisateur** : accès restreint aux sociétés autorisées via un filtre dynamique basé sur l’adresse email.
* **Sélection de plages de dates** : choix interactif des périodes dans Looker Studio.



## 🔒 Sécurité et Gestion des Droits

* **Filtrage dynamique dans Looker Studio** basé sur l’email de l’utilisateur connecté (`USER_EMAIL()`).
* **Vues sécurisées (Blended Data)** limitant l’accès uniquement aux sociétés autorisées pour chaque utilisateur.
* **INNER JOIN** optimisés pour éviter les fuites de données hors périmètre.


## 📈 Résultats Obtenus

* 📊 **Optimisation du suivi financier** : réduction de 40 % des délais de clôture mensuelle.
* 🔄 **Automatisation complète** des flux financiers : zéro intervention manuelle.
* 🔐 **Sécurisation accrue** des données avec un filtrage précis par utilisateur.



## 🚀 Comment Lancer le Projet

1. **Exécuter les procédures BigQuery** :

   * PNL → `CALL update_t_o2c_pnl_sap(date_debut, date_fin);`
   * BILAN → `CALL update_t_o2c_PNS_sap(REPLAY_SINCE);`
2. **Configurer les sources de données dans Looker Studio**.
3. **Appliquer les filtres dynamiques**.
4. **Personnaliser les vues pour chaque utilisateur.**

   **Actuellement, une exécution programmée à une date et une heure bien définie est mise en place  sur bigquery afin d'automatiser le processus**


## 🚀 Améliorations Futures possibles 

* **Ajout d’alertes automatisées**  mails automatiques pour notifier des rapprochements.

