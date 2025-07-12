#!/usr/bin/env python
"""
Script de démarrage du serveur Django avec SQLite
"""
import os
import sys
import subprocess

def init_database():
    """Initialise la base de données SQLite Django"""
    print("🔧 Initialisation de la base de données SQLite...")
    
    os.chdir('backend/emploi_django')
    if not os.path.exists('db.sqlite3'):
        print("📝 Création de la base Django...")
        subprocess.run([sys.executable, 'manage.py', 'makemigrations'])
        subprocess.run([sys.executable, 'manage.py', 'migrate'])
        print("✅ Base de données créée!")
    else:
        print("✅ Base de données existante détectée!")
    
    os.chdir('../..')

def run_django_server():
    """Démarre le serveur Django"""
    os.chdir('backend/emploi_django')
    print("🚀 Démarrage du serveur Django sur http://localhost:8000")
    subprocess.run([sys.executable, 'manage.py', 'runserver'])

def main():
    """Fonction principale"""
    print("🎯 Démarrage du serveur Django avec SQLite")
    print("=" * 50)
    
    # Vérifier que nous sommes dans le bon répertoire
    if not os.path.exists('backend'):
        print("❌ Erreur: Veuillez exécuter ce script depuis la racine du projet")
        sys.exit(1)
    
    # Initialiser la base de données
    init_database()
    
    print("\n✅ Base de données initialisée!")
    print("\n🌐 Le serveur va démarrer sur:")
    print("   - Django: http://localhost:8000")
    print("\n⏹️  Appuyez sur Ctrl+C pour arrêter le serveur")
    print("=" * 50)
    
    try:
        run_django_server()
    except KeyboardInterrupt:
        print("\n🛑 Arrêt du serveur...")
        sys.exit(0)

if __name__ == '__main__':
    main() 