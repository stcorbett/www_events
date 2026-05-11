const $ = require("jquery")
window.$ = $
window.jQuery = $

const Rails = require("@rails/ujs")
Rails.start()
window.Rails = Rails

const bootstrap = require("bootstrap")
window.bootstrap = bootstrap

const _ = require("lodash")
window._ = _
window.findKey = _.findKey

require("jquery-ui/ui/version")
require("jquery-ui/ui/widget")
require("jquery-ui/ui/keycode")
require("jquery-ui/ui/position")
require("jquery-ui/ui/unique-id")
require("jquery-ui/ui/widgets/menu")
require("jquery-ui/ui/widgets/autocomplete")
require("timepicker/jquery.timepicker")
require("bootstrap-datepicker/dist/js/bootstrap-datepicker")
require("datepair.js/dist/datepair")
require("datepair.js/dist/jquery.datepair")

require("./legacy/inapp")
require("./legacy/scripts")
require("./legacy/application_legacy")
// Entry point for the build script in your package.json
