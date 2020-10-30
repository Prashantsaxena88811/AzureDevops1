var dict_en = {
  'en': {
    'ShowingResultsOf': 'out of {2} result<pl>s</pl>',
    'ShowingResultsOfWithQuery': 'out of {2} result<pl>s</pl>',
    'INT Product Page': 'Model Information',
    'INT Issue': 'Issue',
    'Category': 'Category',
    'Article Type': 'Article Type',
    'Content Type': 'Content Type',
    'Views': 'Views',
    'Updated On': 'Updated On',
    'Facet_dropdownHeaderLabel': 'Refine results',
    'SearchBox_placeholder': 'Enter your Model # or search term here.',
    'CaseDeflection_EmailUsTitle': 'Suggested Content',
    'CaseDeflection_SelfServiceTitle': 'Related Articles',
    'ClearAllFilters': 'Clear All',
    'Sort_Name_A_to_Z': 'Name (A-Z)',
    'Sort_Name_Z_to_A': 'Name (Z-A)',
    'Non_orderable_msgList' : 'Please contact Account Representative to request price information'
  }
};

String.toLocaleString(dict_en);

if (!window.Coveo) { window.Coveo = {}; }
Coveo.setCustomLanguageDict = function () {
  String.toLocaleString(dict_en);
}
