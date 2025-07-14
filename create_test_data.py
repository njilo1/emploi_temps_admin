#!/usr/bin/env python3
"""
Script pour créer des données de test avec les nouveaux champs jour/heure/salle
"""

import os
import sys
import django

# Ajouter le chemin du projet Django
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend', 'emploi_django'))

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from api.models import Classe, Filiere, Salle, Module, Professeur, Emploi, Departement

def create_test_data():
    """Crée des données de test pour tester l'algorithme"""
    print("🔧 Création des données de test...")
    
    # Créer un département
    dept = Departement.objects.create(
        nom="Informatique",
        chef="Dr. Smith"
    )
    print(f"   ✅ Département créé: {dept.nom}")
    
    # Créer une filière
    filiere = Filiere.objects.create(
        nom="TIC"
    )
    print(f"   ✅ Filière créée: {filiere.nom}")
    
    # Créer une classe
    classe = Classe.objects.create(
        nom="TIC L1",
        effectif=30,
        filiere=filiere
    )
    print(f"   ✅ Classe créée: {classe.nom}")
    
    # Créer des professeurs
    prof1 = Professeur.objects.create(nom="Prof. Martin")
    prof2 = Professeur.objects.create(nom="Prof. Dubois")
    print(f"   ✅ Professeurs créés: {prof1.nom}, {prof2.nom}")
    
    # Créer des salles
    salle1 = Salle.objects.create(nom="Salle A", capacite=35, disponible=True)
    salle2 = Salle.objects.create(nom="Salle B", capacite=30, disponible=True)
    print(f"   ✅ Salles créées: {salle1.nom}, {salle2.nom}")
    
    # Créer des modules avec jour/heure/salle spécifiques
    module1 = Module.objects.create(
        nom="Mathématiques",
        prof=prof1,
        classe=classe,
        salle=salle1,
        jour="Lundi",
        heure="07H30 - 10H00",
        jours="Lundi"
    )
    print(f"   ✅ Module créé: {module1.nom}")
    print(f"      Jour: {module1.jour}")
    print(f"      Heure: {module1.heure}")
    print(f"      Salle: {module1.salle.nom}")
    
    module2 = Module.objects.create(
        nom="Programmation",
        prof=prof2,
        classe=classe,
        salle=salle2,
        jour="Mardi",
        heure="10H15 - 12H45",
        jours="Mardi"
    )
    print(f"   ✅ Module créé: {module2.nom}")
    print(f"      Jour: {module2.jour}")
    print(f"      Heure: {module2.heure}")
    print(f"      Salle: {module2.salle.nom}")
    
    print("\n🎉 Données de test créées avec succès !")
    print("📝 Vous pouvez maintenant tester la génération d'emploi du temps.")
    print("🔍 Les modules ont des jour/heure/salle spécifiques définis.")

if __name__ == "__main__":
    create_test_data() 