import pandas as pd

# Spécifiez le type de données pour les colonnes problématiques (remplacez 'int' par 'str' ou le type approprié)


# Gérer les lignes problématiques en utilisant 'on_bad_lines'
class MyData :
    companyParameters = []
    taxe = "CFE" # Exemple
    tarif = 0
    exonerations = []

    def __init__(self,taxe,tarif,exonerations):
        pass
df = pd.read_excel('Classeur1.xlsx')

attributs = {
    ""
}

print(df)
