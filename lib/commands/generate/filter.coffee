"use strict"

_ = require "lodash"
Promise = require "bluebird"

Runner = require "../../util/Runner"
runner = new Runner()

LineUp = require "lineup"
lineup = new LineUp()

###*
  # Class to fetch and run hooks registered for generate:filter process/command
  # @class Filter
  # @constructor
###
class Filter

  ###*
    # @method run
    # @param args {Object} accept arguments passed with generate:filter command
    # @description Entry point to generate:filter command and run all registered hooks
  ###
  run: (args) ->
    runner.sortModules("generate:filter")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        runner.getConfig (err,ngconfig) ->
          if err
            runner.trace err
            return
          else
            runner.run "generate:filter",hooks_to_proccess,ngconfig,args
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

module.exports = Filter
