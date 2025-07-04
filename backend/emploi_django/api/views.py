from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Classe, Filiere, Salle, Module, Professeur, Emploi, Departement
from .serializers import (
    ClasseSerializer, FiliereSerializer, SalleSerializer,
    ModuleSerializer, ProfesseurSerializer, EmploiSerializer, DepartementSerializer
)

# ======== CRUD ViewSets ========
class ClasseViewSet(viewsets.ModelViewSet):
    queryset = Classe.objects.all()
    serializer_class = ClasseSerializer

class FiliereViewSet(viewsets.ModelViewSet):
    queryset = Filiere.objects.all()
    serializer_class = FiliereSerializer

class DepartementViewSet(viewsets.ModelViewSet):
    queryset = Departement.objects.all()
    serializer_class = DepartementSerializer

class SalleViewSet(viewsets.ModelViewSet):
    queryset = Salle.objects.all()
    serializer_class = SalleSerializer

class ModuleViewSet(viewsets.ModelViewSet):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer

class ProfesseurViewSet(viewsets.ModelViewSet):
    queryset = Professeur.objects.all()
    serializer_class = ProfesseurSerializer

class EmploiViewSet(viewsets.ModelViewSet):
    queryset = Emploi.objects.all()
    serializer_class = EmploiSerializer

# ======== Route POST /emplois/generate/ ========
@api_view(['POST'])
def generer_emplois(request):
    try:
        tranches_horaires = [
            '07H30 - 10H00',
            '10H15 - 12H45',
            '13H00 - 15H30',
            '15H45 - 18H15',
        ]
        jours_semaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']

        Emploi.objects.all().delete()

        classes = Classe.objects.all()
        salles = Salle.objects.filter(disponible=True)
        modules = Module.objects.all()

        salle_occupe = {}
        prof_occupe = {}

        for classe in classes:
            for module in modules:
                heures_restantes = getattr(module, 'volume_horaire', 3)
                prof = getattr(module, 'prof', None)
                if not prof:
                    continue

                for jour in jours_semaine:
                    for heure in tranches_horaires:
                        cle = f"{jour}-{heure}"
                        salle_id = None

                        for salle in salles:
                            if salle.capacite >= classe.effectif and cle not in salle_occupe.get(salle.id, set()):
                                salle_id = salle.id
                                salle_occupe.setdefault(salle.id, set()).add(cle)
                                break

                        prof_id = prof.id
                        if salle_id and cle not in prof_occupe.get(prof_id, set()):
                            prof_occupe.setdefault(prof_id, set()).add(cle)

                            Emploi.objects.create(
                                classe=classe,
                                module=module,
                                prof=prof,
                                salle=Salle.objects.get(id=salle_id),
                                jour=jour,
                                heure=heure
                            )
                            heures_restantes -= 3
                            if heures_restantes <= 0:
                                break
                    if heures_restantes <= 0:
                        break

        return Response({"message": "Emplois générés avec succès"}, status=200)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

# ======== Route GET /emplois/classe/<id>/ ========
@api_view(['GET'])
def emploi_par_classe(request, classe_id):
    try:
        classe = Classe.objects.get(id=classe_id)
        emplois = Emploi.objects.filter(classe=classe)

        data = {}
        for emploi in emplois:
            jour = emploi.jour
            heure = emploi.heure
            libelle = f"{emploi.module.nom} – {emploi.salle.nom} – {emploi.prof.nom}"

            if jour not in data:
                data[jour] = {}
            data[jour][heure] = libelle

        return Response(data)
    except Classe.DoesNotExist:
        return Response({"error": "Classe introuvable"}, status=404)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

# ======== Route POST /emplois/import/ ========
@api_view(['POST'])
def import_emplois(request):
    try:
        data = request.data.get('emplois', [])
        if not data:
            return Response({"error": "Aucune donnée à importer"}, status=400)

        Emploi.objects.all().delete()

        for item in data:
            classe_nom = item.get('classe')
            module_nom = item.get('module')
            prof_nom = item.get('prof')
            salle_nom = item.get('salle')
            jour = item.get('jour')
            heure = item.get('heure')

            if not (classe_nom and module_nom and prof_nom and salle_nom and jour and heure):
                return Response({"error": f"Donnée incomplète : {item}"}, status=400)

            classe, _ = Classe.objects.get_or_create(nom=classe_nom, defaults={"effectif": 30})
            prof, _ = Professeur.objects.get_or_create(nom=prof_nom)
            salle, _ = Salle.objects.get_or_create(nom=salle_nom, defaults={"capacite": 30, "disponible": True})
            module, _ = Module.objects.get_or_create(nom=module_nom, defaults={"classe": classe, "prof": prof})

            if module.classe != classe or module.prof != prof:
                module.classe = classe
                module.prof = prof
                module.save()

            Emploi.objects.create(
                classe=classe,
                module=module,
                prof=prof,
                salle=salle,
                jour=jour,
                heure=heure
            )

        return Response({"message": "Importation réussie"}, status=200)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)
