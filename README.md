# Emploi Temps Admin

Application de gestion d'emploi du temps avec interface Flutter et backend Django.

## 🚀 Démarrage Rapide

### Linux/macOS
```bash
chmod +x start_all_platforms.sh
./start_all_platforms.sh
```

### Windows
```cmd
start_windows.bat
```

### macOS (spécifique)
```bash
chmod +x start_macos.sh
./start_macos.sh
```

## 📋 Prérequis

### Linux (Ubuntu/Debian/Kali)
- Python 3.8+
- Flutter SDK
- Git

### macOS
- Xcode (pour le développement)
- Homebrew (recommandé)
- Python 3.8+
- Flutter SDK

### Windows
- Python 3.8+
- Flutter SDK
- Git Bash (recommandé)

## 🔧 Installation Manuelle

### 1. Cloner le projet
```bash
git clone <repository-url>
cd emploi_temps_admin
```

### 2. Installer les dépendances Python
```bash
python3 -m venv .venv
source .venv/bin/activate  # Linux/macOS
# ou
.venv\Scripts\activate.bat  # Windows

pip install -r backend/emploi_django/requirements.txt
```

### 3. Initialiser la base de données Django
```bash
cd backend/emploi_django
python manage.py makemigrations
python manage.py migrate
cd ../..
```

### 4. Installer les dépendances Flutter
```bash
flutter pub get
```

## 🏃‍♂️ Lancement

### Option 1: Script automatique (recommandé)
```bash
./start_all_platforms.sh  # Linux/macOS
# ou
start_windows.bat         # Windows
```

### Option 2: Lancement manuel

#### Terminal 1 - Serveur Django
```bash
cd backend/emploi_django
source ../../.venv/bin/activate
python manage.py runserver 0.0.0.0:8000
```

#### Terminal 2 - Application Flutter
```bash
flutter run -d linux    # Linux
flutter run -d macos    # macOS
flutter run -d windows  # Windows
```

## 🌐 Accès

- **Application Flutter**: Interface graphique native
- **API Django**: http://localhost:8000/api/
- **Admin Django**: http://localhost:8000/admin/

## 📁 Structure du Projet

```
emploi_temps_admin/
├── backend/
│   └── emploi_django/          # Backend Django
├── lib/                        # Code Flutter
├── assets/                     # Ressources
├── start_all_platforms.sh      # Script Linux/macOS
├── start_windows.bat          # Script Windows
├── start_macos.sh             # Script macOS spécifique
└── README.md
```

## 🛠️ Développement

### Ajouter une nouvelle fonctionnalité

1. **Backend (Django)**
   ```bash
   cd backend/emploi_django
   source ../../.venv/bin/activate
   python manage.py startapp mon_app
   ```

2. **Frontend (Flutter)**
   ```bash
   # Créer un nouveau widget dans lib/widgets/
   # Ajouter la logique dans lib/services/
   ```

### Tests
```bash
# Tests Django
cd backend/emploi_django
python manage.py test

# Tests Flutter
flutter test
```

## 🔧 Configuration

### Variables d'environnement
Créer un fichier `.env` à la racine :
```env
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_URL=sqlite:///db.sqlite3
```

### Configuration Django
Modifier `backend/emploi_django/emploi_django/settings.py` selon vos besoins.

## 📱 Plateformes Supportées

- ✅ **Linux** (Ubuntu, Debian, Kali)
- ✅ **macOS** (10.15+)
- ✅ **Windows** (10/11)
- ✅ **Android** (via Flutter)
- ✅ **iOS** (via Flutter)

## 🐛 Dépannage

### Problème de permissions (Linux)
```bash
chmod +x *.sh
```

### Problème de port déjà utilisé
```bash
# Linux/macOS
lsof -ti:8000 | xargs kill -9

# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

### Problème de dépendances Python
```bash
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r backend/emploi_django/requirements.txt
```

### Problème Flutter
```bash
flutter clean
flutter pub get
flutter doctor
```

## 📄 Licence

Ce projet est sous licence MIT.

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement
