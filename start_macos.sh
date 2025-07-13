#!/bin/bash

# Script de lancement pour macOS
# Compatible macOS 10.15+

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis macOS
check_macos_prerequisites() {
    print_status "Vérification des prérequis macOS..."
    
    # Vérifier Homebrew
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew n'est pas installé. Installez-le avec: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        print_status "Installation de Flutter via Homebrew..."
        brew install --cask flutter
    fi
    
    # Vérifier Python
    if ! command -v python3 &> /dev/null; then
        print_status "Installation de Python via Homebrew..."
        brew install python
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Installation des dépendances Python
install_python_deps() {
    print_status "Installation des dépendances Python..."
    
    if [ ! -d ".venv" ]; then
        print_status "Création de l'environnement virtuel Python..."
        python3 -m venv .venv
    fi
    
    source .venv/bin/activate
    pip install -r backend/emploi_django/requirements.txt
    print_success "Dépendances Python installées"
}

# Initialisation de la base de données Django
init_django_db() {
    print_status "Initialisation de la base de données Django..."
    
    cd backend/emploi_django
    source ../../.venv/bin/activate
    
    if [ ! -f "db.sqlite3" ]; then
        print_status "Création de la base de données..."
        python manage.py makemigrations
        python manage.py migrate
        print_success "Base de données créée"
    else
        print_success "Base de données existante détectée"
    fi
    
    cd ../..
}

# Démarrage du serveur Django
start_django_server() {
    print_status "Démarrage du serveur Django..."
    
    cd backend/emploi_django
    source ../../.venv/bin/activate
    
    # Démarrer Django en arrière-plan
    python manage.py runserver 0.0.0.0:8000 &
    DJANGO_PID=$!
    echo $DJANGO_PID > ../../django.pid
    
    print_success "Serveur Django démarré sur http://localhost:8000 (PID: $DJANGO_PID)"
    cd ../..
}

# Démarrage de Flutter sur macOS
start_flutter_app() {
    print_status "Démarrage de l'application Flutter sur macOS..."
    
    # Vérifier si Xcode est installé
    if ! xcode-select -p &> /dev/null; then
        print_error "Xcode n'est pas installé. Installez-le depuis l'App Store"
        exit 1
    fi
    
    # Accepter les licences Xcode
    sudo xcodebuild -license accept
    
    flutter run -d macos
}

# Nettoyage à la sortie
cleanup() {
    print_status "Arrêt des services..."
    
    if [ -f "django.pid" ]; then
        DJANGO_PID=$(cat django.pid)
        if kill -0 $DJANGO_PID 2>/dev/null; then
            kill $DJANGO_PID
            print_success "Serveur Django arrêté"
        fi
        rm -f django.pid
    fi
}

# Gestion des signaux pour le nettoyage
trap cleanup EXIT INT TERM

# Fonction principale
main() {
    echo "🚀 Démarrage de l'application Emploi Temps Admin (macOS)"
    echo "========================================================"
    
    # Vérifier les prérequis macOS
    check_macos_prerequisites
    
    # Installer les dépendances
    install_python_deps
    
    # Initialiser la base de données
    init_django_db
    
    # Démarrer Django
    start_django_server
    
    # Attendre un peu que Django démarre
    sleep 3
    
    # Démarrer Flutter
    start_flutter_app
}

# Exécution du script
main "$@" 