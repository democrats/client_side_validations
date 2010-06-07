/* Additional jQueryValidator methods */

if (typeof(jQuery) != "undefined") {
  if (typeof($('').validate) != "undefined") {
    jQuery.validator.addMethod("format", function(value, element, params) { 
        var pattern = new RegExp(params, "i");
        return this.optional(element) || pattern.test(value); 
    }, jQuery.validator.format("Invalid format."));
  }
}

(function($) {
$.extend($.fn, {
  clientSideValidations: function(url, adapter) {
    if (/new/.test(this.id)) {
      var id = /new_(\w+)/.exec(this.id)[1]
    } else if (/edit/.test(this.id)) {
      var id = /edit_(\w+)_\d+/.exec(this.id)[1]
    }
    var client = new ClientSideValidations(id, adapter)
    $.getJSON(url, function(json) {
      var validations = client.adaptValidations(json);
      this.validate({
        rules:    validations.rules,
        messages: validations.messages
      });
    });
  }
});
});

ClientSideValidations = function(id, adapter) {
  this.id                = id;
  this.adapter           = adapter;
  this.adaptValidations  = function(validations) {
    this.validations           = validations;
    this.jQueryValidateAdapter = function() {
      rules    = {}
      messages = {}
      for(var attr in this.validations) {
        name           = this.id + '[' + attr + ']';
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
              break;
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
        return this.jQueryValidateAdapter();
        break;
      default:
    }
  };
}