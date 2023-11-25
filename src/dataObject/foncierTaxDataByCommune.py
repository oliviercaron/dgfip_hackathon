import json;
import pandas as pd
import os

class FoncierTaxDataByCommune:

    def __init__(self, nameDepartement, departementNumber, default_save_path="departemental_tax_values"):

            try:
                geojson_url = f"https://france-geojson.gregoiredavid.fr/repo/departements/{departementNumber}-{nameDepartement}/departement-{departementNumber}-{nameDepartement}.geojson"
                response_geojson_data = self.fetch_geojson(geojson_url)
            except Exception as e:
                raise Exception(f"Une erreur s'est produite lors de la récupération des données GeoJSON : {e}")

            commune_data = [(feature['properties']['nom'], feature['properties']['code']) for feature in response_geojson_data['features']]
            df_communes = pd.DataFrame(commune_data, columns=['Nom_commune', 'Code_commune'])
            self.commune_data = commune_data;
            self.df_communes = df_communes;
            self.nameDepartement = nameDepartement;
            self.default_save_path = default_save_path
            os.makedirs(self.default_save_path, exist_ok=True)

    def save_to_csv(self,csv_file_path=None):
        if csv_file_path is None:
            csv_file_path = os.path.join(self.default_save_path, f"{self.nameDepartement}.csv")

        try:
            self.df_communes.to_csv(csv_file_path, index=False, sep=';', encoding='utf-8-sig')
            print(f"Le fichier a été enregistré avec succès : {csv_file_path}")
        except Exception as e:
            print(f"Erreur lors de l'enregistrement du fichier : {e}")

    def add_tax_column(self, tax_column_name, tax_data):
        self.df_communes[tax_column_name] = pd.np.nan

        for commune_code, tax_value in tax_data.items():
            self.df_communes.loc[self.df_communes['Code_commune'] == commune_code, tax_column_name] = tax_value

        self.save_to_csv()

    def get_commune_codes(self):
        return self.df_communes['Code_commune']
