/* Additional jQueryValidator methods */

jQuery.validator.addMethod("format", function(value, element, params) { 
    var pattern = new RegExp(params, "i");
    return this.optional(element) || pattern.test(value); 
}, jQuery.validator.format("Invalid format."));

function jQueryValidateAdapter(object, validations) {
  rules    = {}
  messages = {}
  for(var attr in validations) {
    name = object + '[' + attr + ']';
    rules[name]    = {};
    messages[name] = {};
    for(var validation in validations[attr]) {
      rule = null;
      switch(validation) {
        case 'presence':
          rule  = 'required'
          value = true;
          break;
        case 'format':
          value = validations[attr][validation]['with'];
          break;
        case 'numericality':
          rule  = 'digits';
          value = true;
        case 'length':
          if('minimum' in validations[attr][validation]) {
            rule  = 'minlength';
            value = validations[attr][validation]['minimum'];
          } else if('maximum' in validations[attr][validation]) {
            rule  = 'maxlength';
            value = validations[attr][validation]['maximum'];
          }
        default:
      }
      if(rule == null) {
        rule = validation;
      }
      rules[name][rule]    = value;
      messages[name][rule] = validations[attr][validation]['message'];
    }
  }
  
  result = {
    rules : rules,
    messages : messages
  };
  
  return result;
}