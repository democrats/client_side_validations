if (typeof(jQuery) != "undefined") {
  jQuery.validator.addMethod("format", function(value, element, params) { 
    var pattern = new RegExp(params, "i");
    return this.optional(element) || pattern.test(value); 
  }, jQuery.validator.format("Invalid format."));
  
  $.extend($.fn, {
    clientSideValidations: function() {
      var form      = this;
      var object    = form.attr('object-csv');
      var id        = form[0].id;
      var object_id = null;
      var adapter   = 'jquery.validate';
      if (/new/.test(id)) {
        id = /new_(\w+)/.exec(id)[1]
      } else if (/edit/.test(id)) {
        id        = /edit_(\w+)_\d+/.exec(id)[1]
        object_id = /edit_\w+_(\d+)/.exec(id)[1]
      }
      var client      = new ClientSideValidations(id, adapter, object_id)
      var json        = eval(object + '_validation_rules');
      var validations = client.adaptValidations(json);
      form.validate({
        rules:    validations.rules,
        messages: validations.messages
      });
    }
  });

  $(document).ready(function() {
    $('form[object-csv]').clientSideValidations();
  });
}

ClientSideValidations = function(id, adapter, object_id) {
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
            case 'uniqueness':
              rule  = 'remote';
              value = {
                url: '/validations/uniqueness.json',
                data: {}
              }
              if(object_id) {
                value['data'][this.id + '[id]'] = function() {
                  return String(object_id);
                }
              }
              break;
            case 'confirmation':
              rule  = 'equalTo';
              value = "[name='" + this.id + "[" + attr + "_confirmation]"  + "']";
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