from django.db import models

# -------- FILIERE --------
class Filiere(models.Model):
    nom = models.CharField(max_length=100)

    def __str__(self):
        return self.nom

# -------- Departement --------
class Departement(models.Model):
    nom = models.CharField(max_length=100)
    chef = models.CharField(max_length=100)

    def __str__(self):
        return self.nom

# -------- CLASSE --------
class Classe(models.Model):
    nom = models.CharField(max_length=100)
    effectif = models.PositiveIntegerField()
    filiere = models.ForeignKey(Filiere, on_delete=models.CASCADE, related_name='classes')

    def __str__(self):
        return self.nom

# -------- SALLE --------
class Salle(models.Model):
    nom = models.CharField(max_length=100)
    capacite = models.PositiveIntegerField()
    disponible = models.BooleanField(default=True)

    def __str__(self):
        return self.nom

# -------- PROFESSEUR --------
class Professeur(models.Model):
    nom = models.CharField(max_length=100)

    def __str__(self):
        return self.nom

# -------- MODULE --------
class Module(models.Model):
    nom = models.CharField(max_length=100)
    volume_horaire = models.PositiveIntegerField(default=3)
    prof = models.ForeignKey(Professeur, on_delete=models.SET_NULL, null=True)
    classe = models.ForeignKey('Classe', on_delete=models.CASCADE, default=1)


    def __str__(self):
        return self.nom

# -------- EMPLOI DU TEMPS --------
class Emploi(models.Model):
    JOUR_CHOICES = [
        ('Lundi', 'Lundi'),
        ('Mardi', 'Mardi'),
        ('Mercredi', 'Mercredi'),
        ('Jeudi', 'Jeudi'),
        ('Vendredi', 'Vendredi'),
        ('Samedi', 'Samedi'),
    ]

    jour = models.CharField(max_length=20, choices=JOUR_CHOICES)
    heure = models.CharField(max_length=50)  # ex : "07H30 - 10H15"
    classe = models.ForeignKey(Classe, on_delete=models.CASCADE, related_name='emplois')
    module = models.ForeignKey(Module, on_delete=models.CASCADE)
    prof = models.ForeignKey(Professeur, on_delete=models.CASCADE)
    salle = models.ForeignKey(Salle, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.jour} - {self.classe.nom} - {self.heure}"

