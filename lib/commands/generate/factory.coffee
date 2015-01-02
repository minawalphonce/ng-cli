"use strict"

_ = require "lodash"
Promise = require "bluebird"

Runner = require "../../util/Runner"
runner = new Runner()

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
    runner.sortModules("generate:factory")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        runner.getConfig (err,ngconfig) ->
          if err
            runner.trace err
            return
          else
            runner.run "generate:factory",hooks_to_proccess,ngconfig,args
            return
        return
      else
        runner.notify "warn","0 hooks configured for this proccess"
        process.exit 1
        return
    .catch (err) ->
     runner.trace err
     process.exit 1
     return
    return

module.exports = Factory
