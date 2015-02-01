"use strict"

Promise = require "bluebird"
_ = require "lodash"

Helpers = require "./helpers"
helpers = new Helpers()

class HookRunner

  addChildren: (index,identifier,dest) ->
    self = @
    (index[identifier] || [])
    .forEach (val) ->
      dest.push {name:val.name,_init:val.init}
      self.addChildren index, val.name, dest
      return
    return

  runFromProccess: (process_name) ->
    defer = Promise.defer()
    self = @
    dest = []
    helpers._getAppAddons (err,addons) ->
      if err
        helpers._terminate err
        return
      else
        if _.size(addons.hooks) > 0
          proccess_hooks = _.filter addons.hooks, (hook) ->
            hook.hook_for == process_name

          if _.size(proccess_hooks) > 0
            self.addChildren(_.groupBy(proccess_hooks, "after"), undefined, dest)
            defer.resolve dest
          else
            defer.reject {"warn":"0 hooks for #{process_name}"}
            return
        else
          defer.reject {"warn":"0 hooks for #{process_name}"}
          return
    defer.promise


  executeHooks: (args,hooks) ->
    defer = Promise.defer()
    helpers._getNgConfig (err,config) ->
      if err
        defer.reject err
      else
        x = 0
        hooks_methods = _.map hooks , (val) ->
          val._init

        Promise.reduce hooks_methods, (output,process) ->
          helpers.lineup.action.success "executing", "hook #{hooks[x].name}"
          x++
          process config,args
        , 0
        .then (final_output) ->
          defer.resolve final_output
        .catch (err) ->
          defer.reject err
    defer.promise

module.exports = HookRunner
