#!/usr/bin/env python3
"""
Script simple pour tester le système avec les bonnes informations
"""

import os
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'emploi_django.settings')
django.setup()

from django.core.management import execute_from_command_line
from api.models import Module, Classe, Professeur, Salle, Emploi

def test_system():
    """Tester que le système utilise les bonnes informations"""
    print("🧪 Test du système...")
    
    try:
        # 1. Créer des données de test
        print("📝 Création des données de test...")
        
        # Créer une classe
        classe = Classe.objects.create(
            nom="Test Classe",
            filiere="Test",
            effectif=25
        )
        
        # Créer un professeur
        prof = Professeur.objects.create(nom="Dr. Test")
        
        # Créer une salle
        salle = Salle.objects.create(nom="Salle Test", capacite=30, disponible=True)
        
        # Créer un module avec des informations spécifiques
        module = Module.objects.create(
            nom="Module Test",
            jour="Mardi",  # Jour spécifique
            heure="10H15 - 12H45",  # Heure spécifique
            salle=salle,  # Salle spécifique
            classe=classe,
            prof=prof,
            volume_horaire=3,
            jours="Mardi"
        )
        
        print(f"✅ Module créé: {module.nom}")
        print(f"   - Jour: {module.jour}")
        print(f"   - Heure: {module.heure}")
        print(f"   - Salle: {module.salle.nom}")
        
        # 2. Générer l'emploi du temps
        print("\n🎯 Génération de l'emploi du temps...")
        
        # Supprimer les emplois existants
        Emploi.objects.all().delete()
        
        # Générer de nouveaux emplois
        from api.views import EmploiViewSet
        vs = EmploiViewSet()
        vs.generate_emplois()
        
        # 3. Vérifier les emplois créés
        emplois = Emploi.objects.all()
        print(f"\n📅 Emplois créés: {emplois.count()}")
        
        for emploi in emplois:
            print(f"  ✅ {emploi.module.nom}")
            print(f"     - Jour: {emploi.jour}")
            print(f"     - Heure: {emploi.heure}")
            print(f"     - Salle: {emploi.salle.nom}")
            print(f"     - Prof: {emploi.prof.nom}")
            
            # Vérifier que les informations correspondent
            if emploi.jour == module.jour:
                print(f"     ✅ Jour correct: {emploi.jour}")
            else:
                print(f"     ❌ Jour incorrect: attendu {module.jour}, obtenu {emploi.jour}")
                
            if emploi.heure == module.heure:
                print(f"     ✅ Heure correcte: {emploi.heure}")
            else:
                print(f"     ❌ Heure incorrecte: attendue {module.heure}, obtenue {emploi.heure}")
                
            if emploi.salle.nom == module.salle.nom:
                print(f"     ✅ Salle correcte: {emploi.salle.nom}")
            else:
                print(f"     ❌ Salle incorrecte: attendue {module.salle.nom}, obtenue {emploi.salle.nom}")
        
        print("\n🎉 Test terminé !")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")

if __name__ == "__main__":
    test_system() 