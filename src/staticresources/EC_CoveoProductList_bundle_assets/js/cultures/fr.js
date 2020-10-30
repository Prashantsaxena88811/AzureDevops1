var dict_fr = {
  'fr': {
    'ShowingResultsOf': 'Environ {2} résultat<pl>s</pl>',
    'INT Product Page': 'Model Information',
    'INT Issue': 'Issue',
    'Category': 'Catégorie',
    'Article Type': 'Type d\'Article',
    'Content Type': 'Type de Contenu',
    'Views': 'Vues',
    'Updated On': 'Mise à jour le',
    'Facet_dropdownHeaderLabel': 'Affiner les résultats',
    'SearchBox_placeholder': 'Saisissez votre recherche ici',
    'CaseDeflection_EmailUsTitle': 'Contenu Suggéré',
    'CaseDeflection_SelfServiceTitle': 'Articles Suggérés',
    'ClearAllFilters': 'Effacer',
    'Sort_Name_A_to_Z': 'Nom (A-Z)',
    'Sort_Name_Z_to_A': 'Nom (Z-A)',
    'Non_orderable_msgList' : 'Please contact Account Representative to request price information'
  }
};

String.toLocaleString(dict_fr);

if (!window.Coveo) { window.Coveo = {}; }
Coveo.setCustomLanguageDict = function () {
  String.toLocaleString(dict_fr);
}
