"use strict"

Helper = require "./Helpers"
Promise = require "bluebird"
Sync = require "../bundled-commands/Sync"
sync = new Sync()
_ = require "lodash"
Configstore = require "configstore"
conf = new Configstore "angcli"

class Runner extends Helper
   ###*
    # @method addChildren
    # @private
    # @param index {String}
    # @param identifier {String}
    # @return dest {Object}
   ###
   addChildren: (index,identifier,dest) ->
     self = @
     (index[identifier] || [])
     .forEach (val) ->
       dest.push {name:val.name,_init:val.path}
       self.addChildren index, val.name, dest
       return
     return

   sortModules: (attached_with) ->
     defer = Promise.defer()
     if attached_with isnt "new"
       self = @
       self.getConfig (err,config) ->
         if err
           self.trace err
           return
         else
           app_root = config.project_root
           saved_project_root = conf.get "project_root"
           if not saved_project_root or saved_project_root isnt app_root
             self.notify "info","Project changed, re syncing hooks..."
             sync.init()
             .then (response) ->
               sync.fetchModules response
             .then (response) ->
               sync.registerModules response
             .then (success) ->
               self.notify "success",success
               self.serializeModules attached_with
               .then (hooks) ->
                 defer.resolve hooks
                 return
             .catch (err) ->
               defer.reject err
               return
             return
           else
            self.serializeModules attached_with
            .then (hooks) ->
              defer.resolve hooks
              return
      else
        return @.serializeModules attached_with
     defer.promise

   ###*
    # @method sortModules
    # @param attached_with {String} hook-for identifier
    # @return {promise} List of sorted hooks
    # @description sort and return hooks ready to be executed
   ###
   serializeModules: (attached_with) ->
     self = @
     dest = []
     defer = Promise.defer()
     methods = []

     modules = require @local_modules
     if _.size(modules) > 0
       modules = JSON.parse modules

     bundled = require @bundled_modules
     if _.size(bundled) > 0
       bundled = JSON.parse bundled

     modules.standalone = modules.standalone || {}
     modules.depends = modules.depends || {}

     bundled.standalone = bundled.standalone || {}
     bundled.depends = bundled.depends || {}

     modules.standalone = _.zip bundled.standalone,modules.standalone
     modules.depends = _.zip bundled.depends,modules.depends

     modules.standalone = _.chain modules.standalone
     .flatten(true)
     .compact(true)
     .sortBy (val) ->
       val.weight
     .value()

     modules.depends = _.chain modules.depends
     .flatten(true)
     .compact(true)
     .sortBy (val) ->
       val.weight
     .value()

     combinedModules = modules.standalone.concat modules.depends

     combinedModules = _.filter combinedModules, (val) ->
       val.attached == attached_with

     self.addChildren(_.groupBy(combinedModules, "after"), undefined, dest)

     defer.resolve dest

     defer.promise

module.exports = Runner
