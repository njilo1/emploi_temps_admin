from rest_framework import serializers
from .models import Classe, Filiere, Salle, Module, Professeur, Emploi, Departement

class ClasseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Classe
        fields = '__all__'

class FiliereSerializer(serializers.ModelSerializer):
    class Meta:
        model = Filiere
        fields = '__all__'

class DepartementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Departement
        fields = '__all__'

class SalleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Salle
        fields = '__all__'

class ModuleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Module
        fields = ['id', 'nom', 'volume_horaire', 'prof', 'classe', 'jours', 'jour', 'heure', 'salle']
        # Champs optionnels - ajoutés progressivement
        extra_kwargs = {
            'jour': {'required': False},
            'heure': {'required': False},
            'salle': {'required': False},
        }

class ProfesseurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Professeur
        fields = '__all__'

class EmploiSerializer(serializers.ModelSerializer):
    class Meta:
        model = Emploi
        fields = '__all__'
