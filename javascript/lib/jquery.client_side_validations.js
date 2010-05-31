/* Additional jQueryValidator methods */

if (typeof(jQuery) != "undefined") {
  if (typeof($('').validate) != "undefined") {
    jQuery.validator.addMethod("format", function(value, element, params) { 
        var pattern = new RegExp(params, "i");
        return this.optional(element) || pattern.test(value); 
    }, jQuery.validator.format("Invalid format."));
  }
}

function ClientSideValidation(object, uri, adapter) {
  this.object  = object;
  this.uri     = uri;
  this.adapter = adapter;

  this.adapt_validations = function(validations) {
    this.validations = validations;
    this.jQueryValidateAdapter = function() {
      rules    = {}
      messages = {}
      for(var attr in this.validations) {
        name = this.object + '[' + attr + ']';
        rules[name]    = {};
        messages[name] = {};
        for(var validation in this.validations[attr]) {
          rule = null;
          switch(validation) {
            case 'presence':
              rule  = 'required'
              value = true;
              break;
            case 'format':
              value = this.validations[attr][validation]['with'];
              break;
            case 'numericality':
              rule  = 'digits';
              value = true;
            case 'length':
              if('minimum' in this.validations[attr][validation]) {
                rule  = 'minlength';
                value = this.validations[attr][validation]['minimum'];
              } else if('maximum' in this.validations[attr][validation]) {
                rule  = 'maxlength';
                value = this.validations[attr][validation]['maximum'];
              }
              break;
            default:
          }
          if(rule == null) {
            rule = validation;
          }
          rules[name][rule]    = value;
          messages[name][rule] = this.validations[attr][validation]['message'];
        }
      }

      result = {
        rules : rules,
        messages : messages
      };

      return result;
    };
    
    switch(this.adapter) {
      case 'jquery.validate':
        return this.jQueryValidateAdapter(this.object, this.validations);
      default:
    }
  };
}