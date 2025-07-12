# emploi_temps_admin

Application Flutter pour la gestion des emplois du temps avec backend Django et SQLite.

## 🚀 Configuration SQLite

Ce projet utilise Django avec SQLite comme base de données pour une configuration simplifiée.

### Backend Django

1. **Installation des dépendances :**
   ```bash
   cd backend/emploi_django
   pip install -r requirements.txt
   ```

2. **Initialisation de la base de données SQLite :**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   python manage.py createsuperuser
   ```

3. **Lancement du serveur Django :**
   ```bash
   python manage.py runserver
   ```

### Démarrage automatique

Depuis la racine du projet :
```bash
python start_servers.py
```

## 📱 Application Flutter

### Desktop & Web

Le projet supporte Windows, macOS, Linux et le web en plus du mobile. Utilisez `flutter run -d <platform>` pour cibler une plateforme spécifique :

```bash
flutter run -d windows   # sur Windows
flutter run -d macos     # sur macOS
flutter run -d linux     # sur Linux
flutter run -d chrome    # Web
```

## 🗄️ Base de données SQLite

- **Django :** `backend/emploi_django/db.sqlite3`

Le fichier de base de données SQLite est automatiquement créé lors de l'initialisation.

## 🔧 API Endpoints

- **GET** `/api/emplois/` - Liste tous les emplois du temps
- **POST** `/api/emplois/` - Créer un nouvel emploi
- **GET** `/api/emplois/{id}/` - Récupérer un emploi spécifique
- **PUT** `/api/emplois/{id}/` - Modifier un emploi
- **DELETE** `/api/emplois/{id}/` - Supprimer un emploi
- **POST** `/api/emplois/generate/` - Générer automatiquement les emplois
- **GET** `/api/emplois/classe/{id}/` - Emploi par classe
- **POST** `/api/emplois/import/` - Importer des emplois
- **POST** `/api/parse-word/` - Parser un fichier Word (.docx)

## 🧪 Tests

Pour tester l'API :
```bash
python test_api.py
```

## 🐛 Débogage

Si vous rencontrez des erreurs lors de l'import :
1. Vérifiez que le serveur Django est démarré
2. Consultez les logs du serveur pour voir les messages de débogage
3. Utilisez le script de test pour vérifier l'API
4. Assurez-vous que les données sont au bon format JSON
