@echo off
REM Script de lancement pour Windows
REM Compatible avec Windows 10/11

echo 🚀 Démarrage de l'application Emploi Temps Admin
echo ================================================

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python n'est pas installé. Veuillez l'installer depuis https://python.org
    pause
    exit /b 1
)

REM Vérifier si Flutter est installé
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter n'est pas installé. Veuillez l'installer depuis https://flutter.dev
    pause
    exit /b 1
)

echo ✅ Prérequis vérifiés

REM Créer l'environnement virtuel s'il n'existe pas
if not exist ".venv" (
    echo 🔧 Création de l'environnement virtuel Python...
    python -m venv .venv
)

REM Activer l'environnement virtuel
call .venv\Scripts\activate.bat

REM Installer les dépendances Python
echo 📦 Installation des dépendances Python...
pip install -r backend\emploi_django\requirements.txt

REM Initialiser la base de données Django
echo 🗄️ Initialisation de la base de données...
cd backend\emploi_django
if not exist "db.sqlite3" (
    python manage.py makemigrations
    python manage.py migrate
    echo ✅ Base de données créée
) else (
    echo ✅ Base de données existante détectée
)

REM Démarrer Django en arrière-plan
echo 🚀 Démarrage du serveur Django...
start /B python manage.py runserver 0.0.0.0:8000

REM Retourner au répertoire racine
cd ..\..

REM Attendre que Django démarre
timeout /t 3 /nobreak >nul

REM Démarrer Flutter
echo 📱 Démarrage de l'application Flutter...
flutter run -d windows

echo 🛑 Arrêt de l'application...
pause 