({
	pad: function(number,helper) {
    if (number < 10) {
      return '0' + number;
    }
    return number;
  },
 
  formatedDateValue: function(formatDate,helper) {
    return formatDate.getFullYear() + '-' + helper.pad(formatDate.getMonth() + 1) + '-' + helper.pad(formatDate.getDate()) + 'T' + helper.pad(formatDate.getHours()) + ':'
              + helper.pad(formatDate.getMinutes()) +  ':' + helper.pad(formatDate.getSeconds());
  }
})