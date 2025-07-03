from django.urls import path, include
from .views import import_emplois  # en haut si pas encore importé
from rest_framework.routers import DefaultRouter
from .views import (
    ClasseViewSet, FiliereViewSet, DepartementViewSet, SalleViewSet,
    ModuleViewSet, ProfesseurViewSet, EmploiViewSet,
    generer_emplois, emploi_par_classe  # ✅ Routes personnalisées bien importées
)

router = DefaultRouter()
router.register(r'classes', ClasseViewSet)
router.register(r'filieres', FiliereViewSet)
router.register(r'departements', DepartementViewSet)
router.register(r'salles', SalleViewSet)
router.register(r'modules', ModuleViewSet)
router.register(r'professeurs', ProfesseurViewSet)
router.register(r'emplois', EmploiViewSet)

urlpatterns = [
    path('', include(router.urls)),

    # ✅ Routes personnalisées bien ajoutées
    path('emplois/generate/', generer_emplois, name='generer_emplois'),
    path('emplois/classe/<int:classe_id>/', emploi_par_classe, name='emploi_par_classe'),
    path('emplois/import/', import_emplois, name='import_emplois'),

]
