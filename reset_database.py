#!/usr/bin/env python3
"""
Script pour effacer complètement la base de données et repartir de zéro
"""

import os
import sys
import django

# Ajouter le chemin du projet Django
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend', 'emploi_django'))

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from django.db import connection
from api.models import Classe, Filiere, Salle, Module, Professeur, Emploi, Departement

def reset_database():
    """Efface complètement la base de données"""
    print("🗑️  Effacement complet de la base de données...")
    
    # Supprimer tous les emplois
    emplois_count = Emploi.objects.count()
    Emploi.objects.all().delete()
    print(f"   ✅ {emplois_count} emplois supprimés")
    
    # Supprimer tous les modules
    modules_count = Module.objects.count()
    Module.objects.all().delete()
    print(f"   ✅ {modules_count} modules supprimés")
    
    # Supprimer toutes les classes
    classes_count = Classe.objects.count()
    Classe.objects.all().delete()
    print(f"   ✅ {classes_count} classes supprimées")
    
    # Supprimer tous les professeurs
    profs_count = Professeur.objects.count()
    Professeur.objects.all().delete()
    print(f"   ✅ {profs_count} professeurs supprimés")
    
    # Supprimer toutes les salles
    salles_count = Salle.objects.count()
    Salle.objects.all().delete()
    print(f"   ✅ {salles_count} salles supprimées")
    
    # Supprimer toutes les filières
    filieres_count = Filiere.objects.count()
    Filiere.objects.all().delete()
    print(f"   ✅ {filieres_count} filières supprimées")
    
    # Supprimer tous les départements
    deps_count = Departement.objects.count()
    Departement.objects.all().delete()
    print(f"   ✅ {deps_count} départements supprimés")
    
    print("\n🎉 Base de données complètement vidée !")
    print("📝 Vous pouvez maintenant ajouter de nouveaux éléments et tester l'algorithme.")

if __name__ == "__main__":
    reset_database() 