"use strict"

_ = require "lodash"
Promise = require "bluebird"

Helpers = require "../util/Helpers"
helpers = new Helpers()

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
        hook_to_run = helpers.fetchHookMethod args.hook
        if hook_to_run
          hook_to_run_object = {name:hook_to_run.name,_init:hook_to_run.path}
          helpers.run "hook",[hook_to_run_object],ngconfig,args
        else
          helpers.notify "error","#{args.command} not found"
          process.exit 1
          return
        return
    return

module.exports = Hook
