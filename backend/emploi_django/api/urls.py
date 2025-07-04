from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import import_emplois
from .views import (
    ClasseViewSet, FiliereViewSet, DepartementViewSet, SalleViewSet,
    ModuleViewSet, ProfesseurViewSet, EmploiViewSet,
    generer_emplois, emploi_par_classe,
)

# Initialisation du routeur pour les ViewSets
router = DefaultRouter()
router.register(r'classes', ClasseViewSet)
router.register(r'filieres', FiliereViewSet)
router.register(r'departements', DepartementViewSet)
router.register(r'salles', SalleViewSet)
router.register(r'modules', ModuleViewSet)
router.register(r'professeurs', ProfesseurViewSet)
router.register(r'emplois', EmploiViewSet)

# Définition des URLs
urlpatterns = [
    # ✅ Routes personnalisées d'abord pour éviter les conflits avec le router
    path('emplois/generate/', generer_emplois, name='generer_emplois'),
    path('emplois/classe/<int:classe_id>/', emploi_par_classe, name='emploi_par_classe'),
    path('emplois/import/', import_emplois, name='import_emplois'),

    path('', include(router.urls)),
]
