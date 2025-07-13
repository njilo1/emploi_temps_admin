from django.urls import path, include
from .views import import_emplois, parse_word_file
from rest_framework.routers import DefaultRouter
from .views import (
    ClasseViewSet, FiliereViewSet, DepartementViewSet,
    SalleViewSet, ModuleViewSet, ProfesseurViewSet, EmploiViewSet,
    generer_emplois, emploi_par_classe,
    clear_emplois
)

router = DefaultRouter()
router.register(r'classes', ClasseViewSet)
router.register(r'filieres', FiliereViewSet)
router.register(r'departements', DepartementViewSet)
router.register(r'salles', SalleViewSet)
router.register(r'modules', ModuleViewSet)
router.register(r'professeurs', ProfesseurViewSet)
# Ne pas enregistrer emplois dans le router pour éviter les conflits
# router.register(r'emplois', EmploiViewSet)

urlpatterns = [
    # ✅ Routes personnalisées d'abord pour éviter les conflits avec le router
    path('emplois/generate/', generer_emplois, name='generer_emplois'),
    path('emplois/classe/<int:classe_id>/', emploi_par_classe, name='emploi_par_classe'),
    path('emplois/import/', import_emplois, name='import_emplois'),
    path('emplois/clear/', clear_emplois, name='clear_emplois'),
    path('parse-word/', parse_word_file, name='parse_word_file'),
    
    # Router à la fin
    path('', include(router.urls)),
]
