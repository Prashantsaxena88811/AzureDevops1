var dict = {
  'ShowingResultsOf': 'Aproximadamente {2} resultado<pl>s</pl>',
  'INT Product Page': 'Model Information',
  'INT Issue': 'Issue',
  'Category': 'Categoría',
  'Article Type': 'Tipo de artículo',
  'Content Type': 'Tipo de contenido',
  'Views': 'Puntos de vista',
  'Updated on': 'Actualizado en',
  'Facet_dropdownHeaderLabel': 'Refinar Resultados',
  'SearchBox_placeholder': 'Escriba su busqueda aqui.',
  'CaseDeflection_EmailUsTitle': 'Contenido sugerido',
  'CaseDeflection_SelfServiceTitle': 'Artículos relacionados',
  'ClearAllFilters': 'Clear All',
  'Sort_Name_A_to_Z': 'Name (A-Z)',
  'Sort_Name_Z_to_A': 'Name (Z-A)',
  'Non_orderable_msgList' : 'Please contact Account Representative to request price information'
};

(function (window) { 
  String.toLocaleString({
    'es-es': dict,
    'es': dict 
  });
})(this);

if(!window.Coveo){window.Coveo = {};}
Coveo.setCustomLanguageDict = function () {
  String.toLocaleString({
    'es-es': dict,
    'es': dict
  });
}

