"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../util/Helpers"
helpers = new Helpers()

LineUp = require "lineup"
lineup = new LineUp()

###*
  # Class to run anonymous hooks from anywhere and for any purpopse
  # @class Hook
  # @constructor
###
class Hook

  ###*
    # @method run
    # @param args {Object} accept arguments passed with hook command
    # @description Entry point to hook command and run all registered hooks
  ###
  run: (args) ->
    helpers.getConfig (err,ngconfig) ->
      if err
        helpers.trace err
        return
      else
        helpers.run "hook",[args.command],ngconfig,args
        return
    return

module.exports = Hook
