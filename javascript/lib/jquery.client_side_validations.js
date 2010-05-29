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