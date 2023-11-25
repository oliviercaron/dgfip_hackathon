# Importer les bibliothèques nécessaires
import dash
from dash import html, dcc, Output, Input
import plotly.express as px

# Initialiser l'application Dash
app = dash.Dash(__name__)

# Définir la mise en page de l'application
app.layout = html.Div([
    dcc.Tabs([
        dcc.Tab(label='Carte', children=[
            dcc.Graph(
                id='map',
                figure=px.scatter_geo()  # Remplacer avec une figure de carte appropriée
            )
        ]),
        dcc.Tab(label='Tableau', children=[
            dcc.Dropdown(
                id='dropdown',
                options=[
                    {'label': '1 fois', 'value': '1'},
                    {'label': '2 fois', 'value': '2'},
                    {'label': '3 fois', 'value': '3'}
                ],
                value='1'
            ),
            dcc.Checklist(
                id='checkbox',
                options=[
                    {'label': 'Cocher pour "Bonjour"', 'value': '1'}
                ],
                value=[]
            ),
            html.Div(id='salutation')
        ])
    ])
])

# Callbacks pour mettre à jour le texte
@app.callback(
    Output('salutation', 'children'),
    [Input('dropdown', 'value'),
     Input('checkbox', 'value')]
)
def update_output(dropdown_value, checkbox_value):
    message = "Bonjour" if '1' in checkbox_value else "Au revoir"
    return ' '.join([message] * int(dropdown_value))

# Exécuter l'application
if __name__ == '__main__':
    app.run_server(debug=True)
