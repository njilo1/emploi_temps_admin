# Generated by Django 5.2.3 on 2025-07-01 14:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0002_module_classe_module_prof_module_volume_horaire'),
    ]

    operations = [
        migrations.CreateModel(
            name='Departement',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nom', models.CharField(max_length=100)),
                ('chef', models.CharField(max_length=100)),
            ],
        ),
    ]
