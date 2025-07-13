#!/bin/bash

# Script de lancement multi-plateformes pour l'application Emploi Temps Admin
# Compatible Linux, macOS, Windows (via WSL)

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Détection de la plateforme
detect_platform() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# Vérification des prérequis
check_prerequisites() {
    print_status "Vérification des prérequis..."
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter n'est pas installé. Veuillez l'installer depuis https://flutter.dev"
        exit 1
    fi
    
    # Vérifier Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 n'est pas installé"
        exit 1
    fi
    
    # Vérifier pip
    if ! command -v pip &> /dev/null; then
        print_error "pip n'est pas installé"
        exit 1
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
    pip install --break-system-packages -r backend/emploi_django/requirements.txt
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

# Démarrage de Flutter
start_flutter_app() {
    print_status "Démarrage de l'application Flutter..."
    
    PLATFORM=$(detect_platform)
    
    case $PLATFORM in
        "linux")
            print_status "Lancement sur Linux..."
            flutter run -d linux
            ;;
        "macos")
            print_status "Lancement sur macOS..."
            flutter run -d macos
            ;;
        "windows")
            print_status "Lancement sur Windows..."
            flutter run -d windows
            ;;
        *)
            print_warning "Plateforme non reconnue, tentative de lancement générique..."
            flutter run
            ;;
    esac
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
    echo "🚀 Démarrage de l'application Emploi Temps Admin"
    echo "================================================"
    
    # Vérifier les prérequis
    check_prerequisites
    
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