// load('javascript/vendor/jquery.js')
// load('javascript/vendor/jquery.validate.js')
load('javascript/vendor/jspec.js')
load('javascript/vendor/jspec.xhr.js')
load('javascript/lib/client_side_validations.js')
load('javascript/jspec/unit/spec.helper.js')

JSpec
.exec('javascript/jspec/unit/jquery.validate.spec.js')
.run({ reporter: JSpec.reporters.Terminal })
.report()