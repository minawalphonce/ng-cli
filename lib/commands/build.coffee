"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../util/Helpers"
helpers = new Helpers()

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
    helpers.sortModules("build")
    .then (hooks_to_proccess) ->
      helpers.getConfig (err,ngconfig) ->
        if err
          helpers.trace err
          return
        else
          helpers.run "generate:controller",hooks_to_proccess,ngconfig,args, () ->
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
              helpers.trace err
              return
          return
      return
    return

module.exports = Sync
