jQuery.validator.addMethod("confirmation", function(value, element) { 
  name                 = element.name.match(/\w+\[(\w+)\]/)[1];
  confirmation_name    = element.name.replace(name, name + '_confirmation')
  confirmation_element = $('[name="'+ confirmation_name +'"]');
  confirmation_element.rules('add', {
    confirmer: $(element)
  })
  return this.optional(element) || value == confirmation_element.attr('value');
}, jQuery.validator.format("Must match confirmation."));

jQuery.validator.addMethod("confirmer", function(value, element, original_element) { 
  original_element.valid();
  return true;
}, jQuery.validator.format(""));

jQuery.validator.addMethod("numericality", function(value, element) { 
  return this.optional(element) || /^(\d+(\.|,)\d+|\d+)$/.test(value);
}, jQuery.validator.format("Is not a number."));

jQuery.validator.addMethod("greater_than", function(value, element, params) {
  return this.optional(element) || parseFloat(value) > params;
}, jQuery.validator.format("Wrong number."));

jQuery.validator.addMethod("less_than", function(value, element, params) {
  return this.optional(element) || parseFloat(value) < params;
}, jQuery.validator.format("Wrong number."));

jQuery.validator.addMethod("odd", function(value, element) { 
  return this.optional(element) || parseInt(value) % 2 == 1;
}, jQuery.validator.format("Must be odd."));

jQuery.validator.addMethod("even", function(value, element) { 
  return this.optional(element) || parseInt(value) % 2 == 0;
}, jQuery.validator.format("Must be even."));

jQuery.validator.addMethod("format", function(value, element, params) { 
  var pattern = new RegExp(params, "i");
  return this.optional(element) || pattern.test(value);
}, jQuery.validator.format("Invalid format."));

jQuery.validator.addMethod("acceptance", function(value, element, params) { 
  return element.checked; 
}, jQuery.validator.format("Was not accepted."));

jQuery.validator.addMethod("inclusion", function(value, element, params) { 
  if (this.optional(element)) {
    return true;
  } else {
    
    for (var i=0, len=params.length; i<len; ++i ) {
      if (value == String(params[i])) {
        return true;
      }
    }
  }
  return false;
}, jQuery.validator.format("Not included in list."));

jQuery.validator.addMethod("exclusion", function(value, element, params) { 
  if (this.optional(element)) {
    return true;
  } else {
    for (var i=0, len=params.length; i<len; ++i ) {
      if (value == String(params[i])) {
        return false;
      }
    }
  }
  return true;
}, jQuery.validator.format("Is reserved."));

jQuery.validator.addMethod("islength", function(value, element, length) { 
  return this.optional(element) || value.length == length;
}, jQuery.validator.format("Is the wrong length."));

$.extend($.fn, {
  clientSideValidations: function() {
    for (var i = 0; i < this.size(); i++) {
      var form                        = $(this[i]);
      var object                      = form.attr('data-csv');
      var validate_options            = eval(object + "_validate_options");
      if (typeof(validate_options['options']) == 'undefined') {
        validate_options['options'] = { };
      }
      validate_options.options.ignore = ':hidden';
      form.validate(validate_options);
    }
  }
});

$(function() {
  $('form[data-csv]').clientSideValidations();
});