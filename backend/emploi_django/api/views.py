from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
from docx import Document
import io
import unicodedata
from .models import Classe, Filiere, Salle, Module, Professeur, Emploi, Departement
from .serializers import (
    ClasseSerializer, FiliereSerializer, SalleSerializer,
    ModuleSerializer, ProfesseurSerializer, EmploiSerializer, DepartementSerializer
)

def clean_text(text):
    """Nettoie le texte en remplaçant les caractères spéciaux"""
    if not text:
        return text
    
    # Remplacer les caractères spéciaux courants
    replacements = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a',
        'î': 'i', 'ï': 'i',
        'ô': 'o', 'ö': 'o',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'ç': 'c',
        '–': '-', '—': '-',  # Tirets
        "'": "'", '"': '"',  # Guillemets
    }
    
    result = text
    for old, new in replacements.items():
        result = result.replace(old, new)
    
    return result

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
        # Vérifier si des départements sont spécifiés
        departements_ids = request.data.get('departements', [])
        
        if departements_ids:
            # Nouvelle logique pour génération par départements
            return generer_emplois_par_departements(request, departements_ids)
        else:
            # Ancienne logique pour génération globale
            return generer_emplois_globaux(request)
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

def generer_emplois_globaux(request):
    """Génération globale (ancienne logique)"""
    try:
        tranches_horaires = [
            '07H30 - 10H00',
            '10H15 - 12H45',
            '13H00 - 15H30',
            '15H45 - 18H15',
        ]

        # Vider tous les emplois existants
        Emploi.objects.all().delete()
        print("🗑️ Tous les emplois existants supprimés")

        classes = Classe.objects.all()
        salles = Salle.objects.filter(disponible=True)
        
        if not classes.exists():
            return Response({"error": "Aucune classe trouvée. Ajoutez d'abord des classes."}, status=400)
        
        if not salles.exists():
            return Response({"error": "Aucune salle disponible trouvée. Ajoutez d'abord des salles."}, status=400)

        salle_occupe = {}
        prof_occupe = {}
        emplois_crees = 0

        print(f"📚 Génération globale pour {classes.count()} classes")
        
        for classe in classes:
            print(f"🎓 Traitement de la classe: {classe.nom}")
            
            # Récupérer seulement les modules associés à cette classe
            modules_classe = Module.objects.filter(classe=classe)
            
            if not modules_classe.exists():
                print(f"⚠️ Aucun module trouvé pour la classe {classe.nom}")
                continue
                
            print(f"📖 Modules pour {classe.nom}: {[m.nom for m in modules_classe]}")

            for module in modules_classe:
                prof = getattr(module, 'prof', None)
                
                if not prof:
                    print(f"⚠️ Module {module.nom} sans professeur, ignoré")
                    continue

                # Récupérer le jour et l'heure spécifiques du module (avec gestion d'erreur)
                try:
                    jour_module = getattr(module, 'jour', None)
                    heure_module = getattr(module, 'heure', None)
                except:
                    # Si les champs n'existent pas encore, utiliser les valeurs par défaut
                    jour_module = None
                    heure_module = None
                
                # Si pas de jour spécifique, utiliser le premier jour des jours autorisés
                if not jour_module:
                    jours_autorises = module.get_jours_list()
                    if jours_autorises:
                        jour_module = jours_autorises[0]
                        print(f"📝 Module {module.nom}: utilisation du premier jour autorisé: {jour_module}")
                    else:
                        print(f"⚠️ Module {module.nom} sans jour spécifique ni jours autorisés, ignoré")
                        continue
                
                # Si pas d'heure spécifique, utiliser la première tranche
                if not heure_module:
                    heure_module = tranches_horaires[0]
                    print(f"📝 Module {module.nom}: utilisation de l'heure par défaut: {heure_module}")
                
                print(f"👨‍🏫 Génération pour {module.nom} (Prof: {prof.nom}, Jour: {jour_module}, Heure: {heure_module})")
                
                cle = f"{jour_module}-{heure_module}"
                
                # Utiliser la salle spécifique du module si elle existe (avec gestion d'erreur)
                try:
                    salle_module = getattr(module, 'salle', None)
                    if salle_module:
                        salle_id = salle_module.id
                        print(f"📝 Module {module.nom}: utilisation de la salle spécifique: {salle_module.nom}")
                    else:
                        # Chercher une salle disponible si aucune salle spécifique
                        salle_id = None
                        for salle in salles:
                            if (salle.capacite >= classe.effectif and 
                                cle not in salle_occupe.get(salle.id, set())):
                                salle_id = salle.id
                                salle_occupe.setdefault(salle.id, set()).add(cle)
                                print(f"📝 Module {module.nom}: salle assignée: {salle.nom}")
                                break
                except:
                    # Si le champ salle n'existe pas encore, chercher une salle disponible
                    salle_id = None
                    for salle in salles:
                        if (salle.capacite >= classe.effectif and 
                            cle not in salle_occupe.get(salle.id, set())):
                            salle_id = salle.id
                            salle_occupe.setdefault(salle.id, set()).add(cle)
                            print(f"📝 Module {module.nom}: salle assignée: {salle.nom}")
                            break

                # Vérifier que le prof n'est pas occupé
                prof_id = prof.id
                if salle_id and cle not in prof_occupe.get(prof_id, set()):
                    prof_occupe.setdefault(prof_id, set()).add(cle)

                    # Créer l'emploi avec les informations spécifiques du module
                    Emploi.objects.create(
                        classe=classe,
                        module=module,
                        prof=prof,
                        salle=Salle.objects.get(id=salle_id),
                        jour=jour_module,
                        heure=heure_module
                    )
                    emplois_crees += 1
                    
                    print(f"✅ Emploi créé: {jour_module} {heure_module} - {module.nom} - {prof.nom} - Salle: {Salle.objects.get(id=salle_id).nom}")
                else:
                    print(f"⚠️ Créneau {jour_module} {heure_module} non disponible pour {module.nom}")

        print(f"🎉 Génération globale terminée: {emplois_crees} emplois créés")
        return Response({
            "message": f"Emplois générés avec succès: {emplois_crees} emplois créés",
            "emplois_crees": emplois_crees
        }, status=200)
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

def generer_emplois_par_departements(request, departements_ids):
    """Génération par départements sélectionnés avec gestion des conflits"""
    from django.db import transaction
    
    try:
        tranches_horaires = [
            '07H30 - 10H00',
            '10H15 - 12H45',
            '13H00 - 15H30',
            '15H45 - 18H15',
        ]
        jours_semaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']

        print(f"🏢 Génération pour les départements: {departements_ids}")
        
        # Récupérer les départements
        departements = Departement.objects.filter(id__in=departements_ids)
        if not departements.exists():
            return Response({"error": "Aucun département trouvé avec les IDs fournis."}, status=400)
        
        # Récupérer toutes les classes des départements sélectionnés
        departements_ids = [d.id for d in departements]
        classes = Classe.objects.filter(filiere__departement_id__in=departements_ids)
        if not classes.exists():
            return Response({"error": "Aucune classe trouvée dans les départements sélectionnés."}, status=400)
        
        # Récupérer toutes les salles disponibles
        salles = Salle.objects.filter(disponible=True)
        if not salles.exists():
            return Response({"error": "Aucune salle disponible trouvée."}, status=400)

        # Vider tous les emplois existants
        Emploi.objects.all().delete()
        print("🗑️ Tous les emplois existants supprimés")

        # Dictionnaires pour gérer les conflits
        salles_occupees = {}  # {jour: {heure: salle_id}}
        profs_occupees = {}   # {jour: {heure: prof_id}}
        emplois_crees = 0
        resultat = {"departements": []}

        with transaction.atomic():
            for departement in departements:
                print(f"🏢 Traitement du département: {departement.nom}")
                departement_data = {
                    "nom": departement.nom,
                    "classes": []
                }
                
                # Récupérer les classes de ce département
                classes_departement = classes.filter(filiere__departement_id=departement.id)
                
                for classe in classes_departement:
                    print(f"🎓 Traitement de la classe: {classe.nom}")
                    classe_data = {
                        "nom": classe.nom,
                        "emplois": {}
                    }
                    
                    # Initialiser la structure des emplois pour cette classe
                    for jour in jours_semaine:
                        classe_data["emplois"][jour] = {}
                        for heure in tranches_horaires:
                            classe_data["emplois"][jour][heure] = ""
                    
                    # Récupérer les modules de cette classe
                    modules_classe = Module.objects.filter(classe=classe)
                    
                    if not modules_classe.exists():
                        print(f"⚠️ Aucun module trouvé pour la classe {classe.nom}")
                        departement_data["classes"].append(classe_data)
                        continue
                    
                    print(f"📖 Modules pour {classe.nom}: {[m.nom for m in modules_classe]}")

                    for module in modules_classe:
                        prof = getattr(module, 'prof', None)
                        
                        if not prof:
                            print(f"⚠️ Module {module.nom} sans professeur, ignoré")
                            continue

                        # Récupérer le jour et l'heure spécifiques du module
                        try:
                            jour_module = getattr(module, 'jour', None)
                            heure_module = getattr(module, 'heure', None)
                        except:
                            jour_module = None
                            heure_module = None
                        
                        # Si pas de jour spécifique, utiliser le premier jour des jours autorisés
                        if not jour_module:
                            jours_autorises = module.get_jours_list()
                            if jours_autorises:
                                jour_module = jours_autorises[0]
                                print(f"📝 Module {module.nom}: utilisation du premier jour autorisé: {jour_module}")
                            else:
                                print(f"⚠️ Module {module.nom} sans jour spécifique ni jours autorisés, ignoré")
                                continue
                        
                        # Si pas d'heure spécifique, utiliser la première tranche
                        if not heure_module:
                            heure_module = tranches_horaires[0]
                            print(f"📝 Module {module.nom}: utilisation de l'heure par défaut: {heure_module}")
                        
                        print(f"👨‍🏫 Génération pour {module.nom} (Prof: {prof.nom}, Jour: {jour_module}, Heure: {heure_module})")
                        
                        # Vérifier les conflits de salle et professeur
                        salle_disponible = None
                        
                        # Utiliser la salle spécifique du module si elle existe
                        try:
                            salle_module = getattr(module, 'salle', None)
                            if salle_module:
                                # Vérifier si cette salle est disponible
                                if (salle_module.disponible and 
                                    salle_module.capacite >= classe.effectif and
                                    (jour_module not in salles_occupees.get(salle_module.id, {}) or
                                     heure_module not in salles_occupees.get(salle_module.id, {}).get(jour_module, {}))):
                                    salle_disponible = salle_module
                                    print(f"📝 Module {module.nom}: utilisation de la salle spécifique: {salle_module.nom}")
                        except:
                            pass
                        
                        # Si pas de salle spécifique ou salle non disponible, chercher une salle libre
                        if not salle_disponible:
                            for salle in salles:
                                if (salle.capacite >= classe.effectif and
                                    (jour_module not in salles_occupees.get(salle.id, {}) or
                                     heure_module not in salles_occupees.get(salle.id, {}).get(jour_module, {}))):
                                    salle_disponible = salle
                                    print(f"📝 Module {module.nom}: salle assignée: {salle.nom}")
                                    break
                        
                        # Vérifier que le professeur n'est pas occupé
                        prof_occupe = False
                        if (jour_module in profs_occupees.get(prof.id, {}) and
                            heure_module in profs_occupees.get(prof.id, {}).get(jour_module, {})):
                            prof_occupe = True
                            print(f"⚠️ Conflit professeur: {prof.nom} déjà occupé le {jour_module} à {heure_module}")
                        
                        # Créer l'emploi si tout est disponible
                        if salle_disponible and not prof_occupe:
                            # Marquer la salle comme occupée
                            if salle_disponible.id not in salles_occupees:
                                salles_occupees[salle_disponible.id] = {}
                            if jour_module not in salles_occupees[salle_disponible.id]:
                                salles_occupees[salle_disponible.id][jour_module] = {}
                            salles_occupees[salle_disponible.id][jour_module][heure_module] = True
                            
                            # Marquer le professeur comme occupé
                            if prof.id not in profs_occupees:
                                profs_occupees[prof.id] = {}
                            if jour_module not in profs_occupees[prof.id]:
                                profs_occupees[prof.id][jour_module] = {}
                            profs_occupees[prof.id][jour_module][heure_module] = True

                            # Créer l'emploi
                            Emploi.objects.create(
                                classe=classe,
                                module=module,
                                prof=prof,
                                salle=salle_disponible,
                                jour=jour_module,
                                heure=heure_module
                            )
                            emplois_crees += 1
                            
                            # Ajouter à la structure de résultat
                            module_nom = clean_text(module.nom)
                            salle_nom = clean_text(salle_disponible.nom)
                            prof_nom = clean_text(prof.nom)
                            libelle = f"{module_nom}\n{salle_nom}\n{prof_nom}"
                            
                            classe_data["emplois"][jour_module][heure_module] = libelle
                            
                            print(f"✅ Emploi créé: {jour_module} {heure_module} - {module.nom} - {prof.nom} - Salle: {salle_disponible.nom}")
                        else:
                            print(f"⚠️ Créneau {jour_module} {heure_module} non disponible pour {module.nom} (salle ou prof occupé)")
                    
                    departement_data["classes"].append(classe_data)
                
                resultat["departements"].append(departement_data)

        print(f"🎉 Génération par départements terminée: {emplois_crees} emplois créés")
        return Response(resultat, status=200)
        
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

        print(f"🔍 Récupération emplois pour classe {classe.nom} (ID: {classe_id})")
        print(f"📊 Nombre d'emplois trouvés: {emplois.count()}")

        # Définir tous les créneaux horaires
        tranches_horaires = [
            '07H30 - 10H00',
            '10H15 - 12H45',
            '13H00 - 15H30',
            '15H45 - 18H15',
        ]
        jours_semaine = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']

        # Initialiser la structure avec tous les créneaux vides
        data = {}
        for jour in jours_semaine:
            data[jour] = {}
            for heure in tranches_horaires:
                data[jour][heure] = ''

        # Remplir avec les emplois existants
        for emploi in emplois:
            jour = emploi.jour
            heure = emploi.heure
            # Nettoyer les caractères spéciaux
            module_nom = clean_text(emploi.module.nom)
            salle_nom = clean_text(emploi.salle.nom)
            prof_nom = clean_text(emploi.prof.nom)
            
            # Format avec sauts de ligne pour un affichage plus propre
            libelle = f"{module_nom}\n{salle_nom}\n{prof_nom}"

            if jour in data and heure in data[jour]:
                data[jour][heure] = libelle
                print(f"📅 Ajout: {jour} {heure} -> {libelle}")

        print(f"📤 Données retournées: {data}")
        return Response(data, content_type='application/json; charset=utf-8')
    except Classe.DoesNotExist:
        print(f"❌ Classe introuvable: {classe_id}")
        return Response({"error": "Classe introuvable"}, status=404)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

# ======== Route POST /emplois/import/ ========
@api_view(['POST'])
def import_emplois(request):
    try:
        import json
        print(f"📦 Requête brute: {request.body}")
        try:
            body = json.loads(request.body)
            print(f"📦 Body JSON: {body}")
        except Exception as e:
            print(f"❌ Erreur parsing JSON: {e}")
        # Gérer les deux formats possibles : request.data ou request.data.get('emplois')
        if isinstance(request.data, list):
            data = request.data
        else:
            data = request.data.get('emplois', [])
        
        print(f"📥 Données reçues: {data}")  # Debug log
        
        if not data:
            return Response({"error": "Aucune donnée à importer"}, status=400)

        Emploi.objects.all().delete()
        emplois_crees = 0

        for item in data:
            try:
                # Gérer les deux formats : noms ou IDs
                if isinstance(item.get('classe'), int):
                    # Format avec IDs
                    classe_id = item.get('classe')
                    module_id = item.get('module')
                    prof_id = item.get('prof')
                    salle_id = item.get('salle')
                    jour = item.get('jour', '').strip()
                    heure = item.get('heure', '').strip()

                    try:
                        classe = Classe.objects.get(id=classe_id)
                        module = Module.objects.get(id=module_id)
                        prof = Professeur.objects.get(id=prof_id)
                        salle = Salle.objects.get(id=salle_id)
                    except (Classe.DoesNotExist, Module.DoesNotExist, Professeur.DoesNotExist, Salle.DoesNotExist):
                        print(f"⚠️ ID introuvable ignoré: {item}")
                        continue

                else:
                    # Format avec noms (nouveau format)
                    classe_nom = item.get('classe', '').strip()
                    module_nom = item.get('module', '').strip()
                    prof_nom = item.get('prof', '').strip()
                    salle_nom = item.get('salle', '').strip()
                    jour = item.get('jour', '').strip()
                    heure = item.get('heure', '').strip()

                    print(f"🔍 Traitement de l'item: {item}")  # Debug log

                    if not (classe_nom and module_nom and prof_nom and salle_nom and jour and heure):
                        print(f"⚠️ Donnée incomplète ignorée: {item}")
                        continue

                    # Créer une filière par défaut si nécessaire
                    filiere, _ = Filiere.objects.get_or_create(nom="Générale")
                    
                    classe, _ = Classe.objects.get_or_create(
                        nom=clean_text(classe_nom), 
                        defaults={"effectif": 30, "filiere": filiere}
                    )
                    prof, _ = Professeur.objects.get_or_create(nom=clean_text(prof_nom))
                    salle, _ = Salle.objects.get_or_create(nom=clean_text(salle_nom), defaults={"capacite": 30, "disponible": True})
                    module, _ = Module.objects.get_or_create(nom=clean_text(module_nom), defaults={"classe": classe, "prof": prof})

                    if module.classe != classe or module.prof != prof:
                        module.classe = classe
                        module.prof = prof
                        module.save()

                # Valider que le jour est dans les choix autorisés
                jours_valides = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
                if jour not in jours_valides:
                    print(f"⚠️ Jour invalide ignoré: {jour} pour l'item {item}")
                    continue

                Emploi.objects.create(
                    classe=classe,
                    module=module,
                    prof=prof,
                    salle=salle,
                    jour=jour,
                    heure=heure
                )
                emplois_crees += 1
                
            except Exception as item_error:
                print(f"❌ Erreur lors du traitement de l'item {item}: {item_error}")
                continue

        return Response({
            "message": f"Importation réussie: {emplois_crees} emplois créés",
            "emplois_crees": emplois_crees
        }, status=200)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

# ======== Route DELETE /emplois/clear/ ========
@api_view(['DELETE'])
def clear_emplois(request):
    try:
        count = Emploi.objects.count()
        Emploi.objects.all().delete()
        return Response({
            "message": f"Base de données vidée : {count} emplois supprimés"
        }, status=200)
    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)

# ======== Route POST /api/parse-word/ ========
@api_view(['POST'])
def parse_word_file(request):
    """Reçoit un fichier Word .docx et retourne les données extraites sous forme de JSON"""
    try:
        if 'file' not in request.FILES:
            return Response({'error': 'Aucun fichier reçu'}, status=400)

        uploaded_file = request.FILES['file']
        if uploaded_file.name == '':
            return Response({'error': 'Fichier vide ou non sélectionné'}, status=400)

        doc_bytes = uploaded_file.read()
        document = Document(io.BytesIO(doc_bytes))
        emplois = []

        if document.tables:
            table = document.tables[0]
            rows = table.rows

            for row in rows[1:]:  # Ignorer l'en-tête
                cells = [cell.text.strip().replace('\n', ' ') for cell in row.cells]
                if any(cells):  # Ignore les lignes totalement vides
                    entry = {}
                    keys = ['classe', 'jour', 'heure', 'module', 'prof', 'salle']
                    for idx, key in enumerate(keys):
                        if idx < len(cells):
                            entry[key] = cells[idx]
                    emplois.append(entry)

        else:
            for para in document.paragraphs:
                line = para.text.strip()
                if not line:
                    continue
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 6:
                    entry = dict(zip(['classe', 'jour', 'heure', 'module', 'prof', 'salle'], parts[:6]))
                    emplois.append(entry)

        # Sauvegarder dans la base de données Django
        for emploi_data in emplois:
            classe_nom = emploi_data.get('classe', '')
            module_nom = emploi_data.get('module', '')
            prof_nom = emploi_data.get('prof', '')
            salle_nom = emploi_data.get('salle', '')
            jour = emploi_data.get('jour', '')
            heure = emploi_data.get('heure', '')

            if classe_nom and module_nom and prof_nom and salle_nom and jour and heure:
                # Créer ou récupérer les objets
                classe, _ = Classe.objects.get_or_create(nom=classe_nom, defaults={"effectif": 30})
                prof, _ = Professeur.objects.get_or_create(nom=prof_nom)
                salle, _ = Salle.objects.get_or_create(nom=salle_nom, defaults={"capacite": 30, "disponible": True})
                module, _ = Module.objects.get_or_create(nom=module_nom, defaults={"classe": classe, "prof": prof})

                # Mettre à jour les relations si nécessaire
                if module.classe != classe or module.prof != prof:
                    module.classe = classe
                    module.prof = prof
                    module.save()

                # Créer l'emploi du temps
                Emploi.objects.create(
                    classe=classe,
                    module=module,
                    prof=prof,
                    salle=salle,
                    jour=jour,
                    heure=heure
                )

        return Response({
            'emplois': emplois, 
            'message': 'Données extraites et sauvegardées avec succès'
        }, status=200)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return Response({'error': f'Erreur lors du traitement : {str(e)}'}, status=500)
