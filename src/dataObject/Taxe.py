from abc import ABC, abstractmethod
import pandas as pd
from src.dataObject.Company import Business
class Taxe(ABC):
    def __init__(self):
        self.resources = {}
        self.callback = None

    def add_resource(self, name, resource_type, path):
        if self.filter_resource(name, resource_type, path):

            self.resources[name] = {'type': resource_type, 'path': path}
            if self.callback:
                self.callback(name, resource_type, path)

    def set_callback(self, callback_function):
        self.callback = callback_function

    @abstractmethod
    def filter_resource(self, name, type, path):
        pass




class CFE(Taxe):
    def __init__(self,department_number,business,taxByCommune):
        self.department_number = department_number;
        self.add_resource("REI","csv","src/res/REI_2022_95_33_16.csv")
        self.add_resource("DELIB", "csv", "src/ress/delib_95_33_16.csv")
        self.REI = None
        self.DELIB = None
        self.business = business
        self.listcommu = taxByCommune.get_commune_codes()

        self.local_rate = 0.0
        self.rental_value = 0.0
        self.intercommunal_rate = 0.0
        self.minimum_base = 0.0
        self.taxByCommune = taxByCommune
        # la taxe que tu cherches est dans self.business.choosen_tax
        filter();



    def filter_resource(self):
       for r in  self.resources :
           if r.name == 'REI':
               data = pd.read_csv(r.path);
               self.REI = data[data['DEPARTEMENT'] == self.department_number]
           if r.name == 'DELIB' :
               data = pd.read_csv(r.path);
               self.DELIB = data[data['DEP'] == self.department_number]


    def CalAll(self):
        tax_data = {}
        for commune in self.listcommu :
            calculate_taxe = self.calculateTaxe(self, commune);
            tax_data[commune] = calculate_taxe;

        self.taxByCommune.add_tax_column();

    def calculateTaxe(self,commune) :
        rate = 0
        commune_data = self.REI[self.REI['COMMUNE'] == commune]

        if not commune_data.empty:
            rate_inter = commune_data['CFE - INTERCOMMUNALITE / TAUX NET / FISCALITE ADDITIONNELLE OU FP DE ZONE (HORS ZONE)'].iloc[0]
            rate_commu = commune_data['CFE - COMMUNE /TAUX NET'].iloc[0]

        rate = rate_inter if rate_inter != 0 else rate_commu
        base = self.calculate_tax_base()
        value = base*rate
        return value;


    def calculate_tax_base(self):
        self.rental_value = 10;

        if self.rental_value is not None:
           base = self.rental_value*self.business.surface * 0.2 * 0.5
        else:
            base = 0.0

        exo = 0
        return base - exo