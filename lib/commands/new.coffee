"use strict"

_ = require "lodash"
Promise = require "bluebird"

Runner = require "../util/Runner"
runner = new Runner()

###*
  # Class to fetch and run hooks registered for new process/command
  # @class New
  # @constructor
###
class New

  ###*
    # @method run
    # @param args {Object} accept arguments passed with new command
    # @description Entry point to new command and run all registered hooks
  ###
  run: (args) ->
    runner.sortModules("new")
    .then (hooks_to_proccess) ->
      if _.size(hooks_to_proccess) > 0
        runner.run "new",hooks_to_proccess,null,args
        return
      else
        runner.notify "warn","0 hooks configured for this proccess"
        process.exit 1
        return
    return

module.exports = New
