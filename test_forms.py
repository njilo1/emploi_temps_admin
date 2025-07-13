#!/usr/bin/env python3
"""
Script de test pour vérifier que tous les formulaires d'ajout fonctionnent
"""

import requests
import json

BASE_URL = "http://localhost:8000/api"

def test_endpoint(endpoint, data, name):
    """Test un endpoint d'ajout"""
    try:
        response = requests.post(f"{BASE_URL}/{endpoint}/", json=data)
        if response.status_code == 201:
            result = response.json()
            print(f"✅ {name} ajouté avec succès: {result}")
            return result
        else:
            print(f"❌ Erreur lors de l'ajout de {name}: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Exception lors de l'ajout de {name}: {e}")
        return None

def main():
    print("🧪 Test des formulaires d'ajout")
    print("=" * 50)
    
    # Test 1: Ajouter une filière
    print("\n1. Test ajout filière...")
    filiere_data = {"nom": "Informatique"}
    filiere = test_endpoint("filieres", filiere_data, "Filière")
    
    # Test 2: Ajouter une classe
    print("\n2. Test ajout classe...")
    classe_data = {
        "nom": "L3 Informatique",
        "effectif": 25,
        "filiere": filiere["id"] if filiere else 1
    }
    classe = test_endpoint("classes", classe_data, "Classe")
    
    # Test 3: Ajouter un professeur
    print("\n3. Test ajout professeur...")
    prof_data = {"nom": "Dr. Jean Dupont"}
    prof = test_endpoint("professeurs", prof_data, "Professeur")
    
    # Test 4: Ajouter une salle
    print("\n4. Test ajout salle...")
    salle_data = {
        "nom": "Salle 101",
        "capacite": 30,
        "disponible": True
    }
    salle = test_endpoint("salles", salle_data, "Salle")
    
    # Test 5: Ajouter un module
    print("\n5. Test ajout module...")
    module_data = {
        "nom": "Programmation Python",
        "volume_horaire": 3,
        "classe": classe["id"] if classe else 1,
        "prof": prof["id"] if prof else 1
    }
    module = test_endpoint("modules", module_data, "Module")
    
    print("\n" + "=" * 50)
    print("🎯 Résumé des tests:")
    
    if all([filiere, classe, prof, salle, module]):
        print("✅ Tous les formulaires fonctionnent correctement!")
        print("\n📊 Données ajoutées:")
        print(f"   - Filière: {filiere['nom']} (ID: {filiere['id']})")
        print(f"   - Classe: {classe['nom']} (ID: {classe['id']})")
        print(f"   - Professeur: {prof['nom']} (ID: {prof['id']})")
        print(f"   - Salle: {salle['nom']} (ID: {salle['id']})")
        print(f"   - Module: {module['nom']} (ID: {module['id']})")
    else:
        print("❌ Certains formulaires ont échoué")
    
    print("\n🌐 Vérification des données...")
    
    # Vérifier que les données sont bien enregistrées
    try:
        filieres = requests.get(f"{BASE_URL}/filieres/").json()
        classes = requests.get(f"{BASE_URL}/classes/").json()
        profs = requests.get(f"{BASE_URL}/professeurs/").json()
        salles = requests.get(f"{BASE_URL}/salles/").json()
        modules = requests.get(f"{BASE_URL}/modules/").json()
        
        print(f"   - Filières: {len(filieres)}")
        print(f"   - Classes: {len(classes)}")
        print(f"   - Professeurs: {len(profs)}")
        print(f"   - Salles: {len(salles)}")
        print(f"   - Modules: {len(modules)}")
        
    except Exception as e:
        print(f"❌ Erreur lors de la vérification: {e}")

if __name__ == "__main__":
    main() 