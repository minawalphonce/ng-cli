"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../../util/Helpers"
helpers = new Helpers()

LineUp = require "lineup"
lineup = new LineUp()

###*
  # Class to fetch and run hooks registered for generate:service process/command
  # @class Service
  # @constructor
###
class Service

  ###*
    # @method run
    # @param args {Object} accept arguments passed with generate:service command
    # @description Entry point to generate:service command and run all registered hooks
  ###
  run: (args) ->
    helpers.sortModules("generate:service")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        helpers.getConfig (err,ngconfig) ->
          if err
            lineup.log.error err
            process.exit 1
            return
          else
            helpers.run "generate:service",hooks_to_proccess,ngconfig,args
            return
        return
      else
        lineup.log.warn "0 hooks configured for this proccess"
        process.exit 1
        return
    return

module.exports = Service
