import pandas as pd

from src.dataObject.Company import Business
import pandas as p

class Data:
    def __init__(self, business, rate, local_rate=None, rental_value=None,
                 exemption=False, communal_rate=None, intercommunal_rate=0.0, minimum_base=0.0):
        self.business = business
        self.rate = rate
        self.local_rate = local_rate
        self.rental_value = rental_value
        self.exemption = exemption
        self.communal_rate = communal_rate
        self.intercommunal_rate = intercommunal_rate
        self.minimum_base = minimum_base
        self.base_tax = self.calculate_min_base_tax()

    def calculate_tax_base(self): # POUR L'INSTANT C'EST UNIQUEMENT POUR LA TAXE CFE
        # Calculate the gross base
        gross_base = self.business.calculate_business_base()

        # Exemption at the group level
        if self.exemption:
            gross_base = 0.0

        # Calculate the rental value if it exists
        if self.rental_value is not None:
            rental_base = self.rental_value * 0.2 * 0.5 # on a pas le coeff de neutralisation mais c'est pas grave
        else:
            rental_base = 0.0


        self.getMinBase()
        # Comparison with the minimum base
        taxable_base = max(gross_base, rental_base, self.minimum_base)

        # Reduce the base based on the nature of the business
        if self.business.business_type == 'artisan':
            taxable_base *= 0.8  # For example, a 20% reduction for artisans

        # Final calculation of CFE based on the rate
        if self.rate != 0.0:
            cfe = self.rate * taxable_base
        else:
            # If the rate is zero, apply the group rate
            cfe = self.communal_rate * self.intercommunal_rate * taxable_base

        return cfe

    def getMinBase(self,code):
        # T'as dis que t'allais le faire, ok ca marche
        delib = pd.read_csv("../ress/delib_95_33_16.csv")
        delib.get(code)
        return #qqchose

    def getCode(self):
        #CAS ICI DE LA CFE
        if self.business.revenue_figure <= 10000:
            return "BAZMINCFE1DAT"
        elif 10000 < self.business.revenue_figure <= 32600:
            return "BAZMINCFE2MT"

        elif 32600 < self.business.revenue_figure <= 100000:
            return "BAZMINCFE3MT"

        elif 100000 < self.business.revenue_figure <= 250000:
            return "BAZMINCFE4MT"

        elif 250000 < self.business.revenue_figure <= 500000:
            return "BAZMINCFE5MT"

        else:  # ca > 500000
            return "BAZMINCFE6MT"

        # Exemple d'utilisation



# Example of usage
business_example = Business(num_employees=10, turnover=1000000, area=500, business_type='artisan')
data_business = Data(business_example, rate=0.02, local_rate=0.01,
                     rental_value=5000, exemption=True, communal_rate=0.015, intercommunal_rate=0.005,
                     minimum_base=10000)

cfe_calculation = data_business.calculate_cfe_base()
print(f'Calculated CFE: {cfe_calculation}')