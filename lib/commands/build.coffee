"use strict"

_ = require "lodash"
Promise = require "bluebird"

Runner = require "../util/Runner"
runner = new Runner()

Tasks = require "../bundled-commands/Tasks"
tasks = new Tasks()

###*
  # Class to sync local and bundled hooks
  # @class Sync
  # @constructor
###
class Sync

  ###*
    # @method run
    # @param args {Object} accept arguments passed with sync command
    # @description Entry point to sync command
  ###
  run: (args,watch) ->
    runner.sortModules("build")
    .then (hooks_to_proccess) ->
      runner.getConfig (err,ngconfig) ->
        if err
          runner.trace err
          return
        else
          runner.run "generate:controller",hooks_to_proccess,ngconfig,args, () ->
            tasks.parse()
            .then () ->
              tasks.runTasks()
            .then () ->
              if watch
                tasks.checkAndStartServer()
                tasks.registerWatchers()
                return
              return
            .catch (err) ->
              runner.trace err
              return
          return
      return
    return

module.exports = Sync
