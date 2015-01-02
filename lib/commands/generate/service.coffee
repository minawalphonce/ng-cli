"use strict"

_ = require "lodash"
Promise = require "bluebird"

Runner = require "../../util/Runner"
runner = new Runner()

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
    runner.sortModules("generate:service")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        runner.getConfig (err,ngconfig) ->
          if err
            lineup.log.error err
            process.exit 1
            return
          else
            runner.run "generate:service",hooks_to_proccess,ngconfig,args
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

module.exports = Service
