#!/usr/bin/env python3
"""
Script pour appliquer les migrations Django
"""

import os
import sys
import subprocess

def apply_migrations():
    """Applique les migrations Django"""
    print("🔧 Application des migrations Django...")
    
    # Chemin vers le projet Django
    django_path = os.path.join(os.path.dirname(__file__), 'backend', 'emploi_django')
    
    try:
        # Changer vers le répertoire Django
        os.chdir(django_path)
        print(f"📁 Répertoire: {os.getcwd()}")
        
        # Créer les migrations
        print("📝 Création des migrations...")
        result = subprocess.run(['python', 'manage.py', 'makemigrations'], 
                              capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("⚠️ Erreurs:", result.stderr)
        
        # Appliquer les migrations
        print("🚀 Application des migrations...")
        result = subprocess.run(['python', 'manage.py', 'migrate'], 
                              capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("⚠️ Erreurs:", result.stderr)
        
        print("✅ Migrations appliquées avec succès !")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'application des migrations: {e}")
    finally:
        # Revenir au répertoire original
        os.chdir(os.path.dirname(__file__))

if __name__ == "__main__":
    apply_migrations() 