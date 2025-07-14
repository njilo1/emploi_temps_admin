#!/usr/bin/env python3
"""
Script pour vérifier et mettre à jour les jours des modules existants
"""

import os
import sys
import django

# Ajouter le chemin du projet Django
sys.path.append(os.path.join(os.path.dirname(__file__), 'backend', 'emploi_django'))

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from api.models import Module

def check_and_update_modules():
    """Vérifie et met à jour les jours des modules"""
    modules = Module.objects.all()
    
    print(f"🔍 Vérification de {modules.count()} modules...")
    
    for module in modules:
        print(f"\n📚 Module: {module.nom}")
        print(f"   Jours actuels: {module.jours}")
        
        jours_list = module.get_jours_list()
        print(f"   Jours parsés: {jours_list}")
        
        # Si tous les jours sont autorisés, proposer une mise à jour
        if len(jours_list) == 6:  # Tous les jours
            print(f"   ⚠️  Ce module a tous les jours autorisés")
            
            # Proposer des jours par défaut basés sur le nom du module
            if "math" in module.nom.lower() or "calcul" in module.nom.lower():
                suggested_days = "Lundi,Mercredi,Vendredi"
            elif "français" in module.nom.lower() or "langue" in module.nom.lower():
                suggested_days = "Mardi,Jeudi"
            elif "sport" in module.nom.lower() or "physique" in module.nom.lower():
                suggested_days = "Lundi,Mercredi"
            else:
                suggested_days = "Mardi,Jeudi,Vendredi"
            
            print(f"   💡 Suggestion: {suggested_days}")
            
            # Demander confirmation pour la mise à jour
            response = input(f"   Voulez-vous mettre à jour ce module? (o/n): ").lower().strip()
            if response in ['o', 'oui', 'y', 'yes']:
                module.jours = suggested_days
                module.save()
                print(f"   ✅ Mis à jour: {module.jours}")
            else:
                print(f"   ❌ Aucune modification")
        else:
            print(f"   ✅ Jours déjà configurés correctement")

if __name__ == "__main__":
    check_and_update_modules() 