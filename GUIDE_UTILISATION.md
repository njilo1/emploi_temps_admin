# 📚 Guide d'utilisation - Système d'emploi du temps

## 🎯 Objectif
Ce système vous permet de créer et gérer des emplois du temps pour vos classes en ajoutant d'abord les données de base, puis en générant automatiquement les emplois.

## 📋 Étapes pour créer un emploi du temps

### 1. **Ajouter les données de base** (dans l'ordre)

#### A. Ajouter un Département
- Menu → "Ajouter Département"
- Remplir : Nom du département + Chef de département
- Exemple : "Informatique" + "Dr. Martin"

#### B. Ajouter une Filière
- Menu → "Ajouter Filière" 
- Remplir : Nom de la filière
- Exemple : "Technologies de l'Information"

#### C. Ajouter des Professeurs
- Menu → "Ajouter Professeur"
- Remplir : Nom du professeur
- Exemple : "Dr. Dupont", "Prof. Smith"

#### D. Ajouter des Salles
- Menu → "Ajouter Salle"
- Remplir : Nom + Capacité + Disponible
- Exemple : "Salle A" + 30 + ✅

#### E. Ajouter des Classes
- Menu → "Ajouter Classe"
- Remplir : Nom + Sélectionner Filière + Effectif
- Exemple : "TIC L1" + "Technologies de l'Information" + 25

#### F. Ajouter des Modules
- Menu → "Ajouter Module"
- Remplir : Nom + Sélectionner Classe + Sélectionner Professeur + Volume horaire
- Exemple : "Mathématiques" + "TIC L1" + "Dr. Dupont" + 6

### 2. **Générer l'emploi du temps**

#### Option A : Génération automatique (Recommandée)
- Aller dans "Générer Emploi du Temps"
- Sélectionner une classe
- Cliquer sur "Générer automatiquement"
- Le système créera un emploi basé sur les modules de cette classe

#### Option B : Import depuis JSON
- Utiliser le fichier `assets/emploi_test.json` comme modèle
- Cliquer sur "Importer depuis JSON"
- Le système créera les entités manquantes automatiquement

## 🔧 Fonctionnalités disponibles

### Boutons principaux :
- **"Générer automatiquement"** : Crée un emploi basé sur les modules de la classe sélectionnée
- **"Importer depuis JSON"** : Importe un emploi depuis un fichier JSON
- **"Vider la base"** : Supprime tous les emplois existants (utile pour recommencer)
- **"Exporter PDF"** : Exporte l'emploi en PDF

### Menu latéral :
- **Ajouter/Voir** : Pour toutes les entités (Classes, Professeurs, Salles, etc.)
- **Générer Emploi du Temps** : Page principale de génération
- **Emploi global** : Voir tous les emplois

## ⚠️ Points importants

### Pour que la génération fonctionne :
1. **Il faut au moins une classe** avec des modules associés
2. **Il faut au moins une salle disponible**
3. **Chaque module doit avoir un professeur assigné**

### Logique de génération :
- Le système utilise **seulement les modules associés à la classe sélectionnée**
- Il respecte les **contraintes de salles** (capacité, disponibilité)
- Il évite les **conflits de professeurs** (un prof ne peut pas être à deux endroits en même temps)
- Il respecte le **volume horaire** de chaque module

## 🐛 Résolution de problèmes

### "Aucune classe trouvée"
- Ajoutez d'abord des classes via le menu

### "Aucune salle disponible"
- Ajoutez des salles et vérifiez qu'elles sont marquées comme "disponibles"

### "Aucun module trouvé pour la classe"
- Ajoutez des modules et associez-les à la classe

### Emplois en double ou conflits
- Utilisez "Vider la base" pour recommencer proprement

## 📊 Structure des données

```
Département
└── Filières
    └── Classes
        └── Modules (avec Professeurs)
            └── Emplois (avec Salles)
```

## 🎨 Conseils d'utilisation

1. **Commencez petit** : Ajoutez une classe, quelques modules, puis testez la génération
2. **Vérifiez les données** : Utilisez "Voir Classes", "Voir Modules" pour vérifier vos données
3. **Testez la génération** : Une fois les données ajoutées, testez la génération automatique
4. **Ajustez si nécessaire** : Modifiez les modules, salles, etc. selon vos besoins

## 🔄 Workflow recommandé

1. **Préparation** : Ajoutez toutes vos données de base (départements, filières, classes, etc.)
2. **Test** : Générez un emploi pour une classe simple
3. **Ajustement** : Modifiez les modules, salles selon les résultats
4. **Production** : Générez les emplois pour toutes vos classes
5. **Export** : Exportez en PDF si nécessaire 