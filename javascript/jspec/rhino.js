
load('vendor/jspec.js')
load('vendor/jspec.xhr.js')
load('lib/client_side_validations.js')
load('jspec/unit/spec.helper.js')

JSpec
.exec('jspec/unit/jquery.validate.spec.js')
.run({ reporter: JSpec.reporters.Terminal, fixturePath: 'spec/fixtures' })
.report()