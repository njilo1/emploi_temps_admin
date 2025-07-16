from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('api', '0005_module_heure_module_jour_module_salle'),
    ]

    operations = [
        migrations.AddField(
            model_name='filiere',
            name='departement',
            field=models.ForeignKey(blank=True, null=True, on_delete=models.CASCADE, related_name='filieres', to='api.departement'),
        ),
    ]
