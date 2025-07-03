from django.contrib import admin

from .models import Classe, Filiere, Departement, Salle, Module, Professeur, Emploi

admin.site.register(Classe)
admin.site.register(Filiere)
admin.site.register(Departement)
admin.site.register(Salle)
admin.site.register(Module)
admin.site.register(Professeur)
admin.site.register(Emploi)
