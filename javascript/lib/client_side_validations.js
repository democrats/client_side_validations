if (typeof(jQuery) != "undefined") {
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
  
  $.extend($.fn, {
    clientSideValidations: function() {
      var form      = this;
      var object    = form.attr('object-csv');
      var form_id   = form[0].id;
      var object_id = null;
      var adapter   = 'jquery.validate';

      if (/edit/.test(form_id)) {
        object_id = /edit_\w+_(\d+)/.exec(form_id)[1];
      }
      
      if (eval("typeof(" + object + "_validation_options)") != "undefined") {
        var options = eval(object + '_validation_options');
      } else {
        var options = { }
      }
      var client       = new ClientSideValidations(object, adapter, object_id)
      var rules        = eval(object + '_validation_rules');
      var validations  = client.adaptValidations(rules);
      options.rules    = validations.rules;
      options.messages = validations.messages;
      options.ignore   = ':hidden';
      form.validate(options);
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
          required = false;
          switch(validation) {
            case 'presence':
              rule  = 'required';
              value = true;
              break;
            case 'format':
              value    = this.validations[attr][validation]['with'];
              required = !this.validations[attr][validation]['allow_blank'];
              break;
            case 'numericality':
              rule     = 'digits';
              value    = true;
              required = !this.validations[attr][validation]['allow_blank'];
              break;
            case 'length':
              if ('minimum' in this.validations[attr][validation] && 'maximum' in this.validations[attr][validation]) {
                maxrule                 = 'maxlength';
                rules[name][maxrule]    = this.validations[attr][validation]['maximum'];
                messages[name][maxrule] = this.validations[attr][validation]['message_max'];
                
                rule     = 'minlength';
                value    = this.validations[attr][validation]['minimum'];
                this.validations[attr][validation]['message'] = this.validations[attr][validation]['message_min']
              } else if('minimum' in this.validations[attr][validation]) {
                rule     = 'minlength';
                value    = this.validations[attr][validation]['minimum'];
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
              required = !this.validations[attr][validation]['allow_blank'];
              break;
            case 'confirmation':
              rule  = 'equalTo';
              value = "[name='" + this.id + "[" + attr + "_confirmation]"  + "']";
              break;
            case 'acceptance':
              rule  = 'acceptance';
              value = true;
              break;
            case 'inclusion':
              rule     = 'inclusion';
              value    = this.validations[attr][validation]['in']
              required = !this.validations[attr][validation]['allow_blank'];
              break;
            case 'exclusion':
              rule     = 'exclusion';
              value    = this.validations[attr][validation]['in']
              required = !this.validations[attr][validation]['allow_blank'];
              break;

            default:
          }
          if(rule == null) {
            rule = validation;
          }
          
          if (typeof(value) != 'undefined') {
            rules[name][rule]    = value;
            messages[name][rule] = this.validations[attr][validation]['message'];
          }
          if (required && rules[name]['required'] == null) {
            rules[name].required    = true;
            messages[name].required = this.validations[attr][validation]['message'];
          }
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