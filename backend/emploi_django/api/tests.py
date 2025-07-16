from django.test import TestCase, Client
from django.urls import reverse
from .models import Departement, Filiere, Classe, Professeur, Salle, Module, Emploi
import json

class GenerationTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.dep1 = Departement.objects.create(nom='Dep1', chef='A')
        self.dep2 = Departement.objects.create(nom='Dep2', chef='B')
        self.fil1 = Filiere.objects.create(nom='Fil1', departement=self.dep1)
        self.fil2 = Filiere.objects.create(nom='Fil2', departement=self.dep2)
        self.cl1 = Classe.objects.create(nom='C1', effectif=20, filiere=self.fil1)
        self.cl2 = Classe.objects.create(nom='C2', effectif=20, filiere=self.fil2)
        self.s1 = Salle.objects.create(nom='S1', capacite=40, disponible=True)
        self.s2 = Salle.objects.create(nom='S2', capacite=40, disponible=True)
        self.p1 = Professeur.objects.create(nom='Prof1')
        self.p2 = Professeur.objects.create(nom='Prof2')
        self.p3 = Professeur.objects.create(nom='Prof3')
        Module.objects.create(nom='Maths', prof=self.p1, classe=self.cl1, jour='Lundi', heure='07H30 - 10H00')
        Module.objects.create(nom='Physique', prof=self.p1, classe=self.cl2, jour='Lundi', heure='07H30 - 10H00')
        Module.objects.create(nom='Chimie', prof=self.p2, classe=self.cl1, jour='Mardi', heure='10H15 - 12H45')
        Module.objects.create(nom='Bio', prof=self.p3, classe=self.cl2, jour='Mardi', heure='10H15 - 12H45')

    def test_prof_not_in_conflict(self):
        self.client.post('/api/emplois/generate/', json.dumps({'departements':[self.dep1.id, self.dep2.id]}), content_type='application/json')
        count = Emploi.objects.filter(prof=self.p1, jour='Lundi', heure='07H30 - 10H00').count()
        self.assertEqual(count, 1)

    def test_unique_room(self):
        self.client.post('/api/emplois/generate/', json.dumps({'departements':[self.dep1.id, self.dep2.id]}), content_type='application/json')
        emplois = Emploi.objects.filter(jour='Mardi', heure='10H15 - 12H45')
        salles = {e.salle_id for e in emplois}
        self.assertEqual(len(salles), len(emplois))
