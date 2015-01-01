"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../util/Helpers"
helpers = new Helpers()

Sync = require "../bundled-commands/Sync"
sync = new Sync()

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
  run: (args) ->
    type = false
    if args.type == "bundled"
      type = "bundled"
    sync.init(type)
    .then (response) ->
      sync.fetchModules response
    .then (response) ->
      sync.registerModules response
    .then (success) ->
      helpers.notify "success",success
      process.exit 0
      return
    .catch (err) ->
      helpers.trace err
      return
    return

module.exports = Sync
