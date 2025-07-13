from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-bwmaah%t@z8&(=+##+!w6+p$iu01-hetdbm&r6i_w%a-_5tnoa'

DEBUG = True

ALLOWED_HOSTS = []

# 🔥 Applications installées
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',        # ✅ Django REST API
    'corsheaders',           # ✅ Autoriser Flutter (Cross-Origin)
    'api',                   # ✅ Ton app personnalisée
]

# 🔥 Middleware
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',   # ✅ CORS EN PREMIER
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'emploi_django.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'emploi_django.wsgi.application'

# 📦 Base de données SQLite
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# 🔐 Validation des mots de passe
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# 🌍 Langue et fuseau horaire
LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Africa/Douala'
USE_I18N = True
USE_TZ = True

# 🔤 Encodage UTF-8
DEFAULT_CHARSET = 'utf-8'

# 📁 Fichiers statiques
STATIC_URL = 'static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# 🌐 CORS (autorise Flutter en localhost)
CORS_ALLOW_ALL_ORIGINS = True

# Ou version plus sécurisée :
# CORS_ALLOWED_ORIGINS = [
#     'http://localhost:8000',
#     'http://127.0.0.1:8000',
#     'http://localhost:PORT_DE_TON_FLUTTER_APP',
# ]
