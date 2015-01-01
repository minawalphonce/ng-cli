"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../../util/Helpers"
helpers = new Helpers()

LineUp = require "lineup"
lineup = new LineUp()

###*
  # Class to fetch and run hooks registered for generate:factory process/command
  # @class Factory
  # @constructor
###
class Factory

  ###*
    # @method run
    # @param args {Object} accept arguments passed with generate:factory command
    # @description Entry point to generate:factory command and run all registered hooks
  ###
  run: (args) ->
    helpers.sortModules("generate:factory")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        helpers.getConfig (err,ngconfig) ->
          if err
            lineup.log.error err
            process.exit 1
            return
          else
            helpers.run "generate:factory",hooks_to_proccess,ngconfig,args
            return
        return
      else
        lineup.log.warn "0 hooks configured for this proccess"
        process.exit 1
        return
    return

module.exports = Factory
