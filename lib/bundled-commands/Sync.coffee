"use strict"

tree = require "read-package-tree"
_ = require "lodash"
path = require "path"
fs = require "fs"
util = require "util"
Promise = require "bluebird"

Helpers = require "../util/Helpers"
register = new Helpers()

LineUp = require "lineup"
lineup = new LineUp()

Configstore = require "configstore"
conf = new Configstore "angcli"

###*
  # Class to sync bundled / local hooks , helps in registering hooks in short
  # @class Sync
  # @constructor
###

class Sync

  constructor: () ->
    ###*
      # @property content_path
      # @type {String} path to content directory to save bundled and app specific hooks
    ###
    @content_path = path.join __dirname,"../../content"
    ###*
      # @property project_path
      # @type {String} path to ngCli root
    ###
    @project_path = path.join __dirname,"../../"

  ###*
    # @method init
    # @param type {String} bundled or nothing
    # @return {promise} Returns promise object with config(if not bundled) and project root
  ###
  init: (type) ->
    defer = Promise.defer()
    if type
      @modules = path.join @content_path,"bundled.js"
      config = {}
      config.project_root = @project_path
      defer.resolve config
    else
      @modules = path.join @content_path,"modules.js"
      register.getConfig (err,config) ->
        if err
          defer.reject err
          return
        else
          defer.resolve config
          return
    defer.promise

  ###*
    # @method fetchModules
    # @param config {Object} config object to obtain project root and scan npm modules for ng hooks
    # @return {promise} Returns promise with list of ng hooks
  ###
  fetchModules: (config) ->
    defer = Promise.defer()
    conf.set "project_root",config.project_root
    project_root = config.project_root
    tree project_root, (err,modules) ->
      if err
        defer.reject err
      else
        hooks = {}
        _.each modules.children,(values) ->
          if values.package["ng-hook"]
            hooks[values.realpath] = values.package["ng-hook"]
            return
        defer.resolve hooks
    defer.promise

  ###*
    # @method registerModules
    # @param modules {Object} Hooks object to register standalone and dependent hooks as local js modules
    # @return {String} Returns promise with success or error on saving hooks
  ###
  registerModules: (modules) ->
    defer = Promise.defer()
    self = @
    standalone = []
    depends = []

    _.each modules, (v,k) ->
      v.weight = v.weight || 0
      if v["hook-for"] and v.name
        if v.after
          _.each v.after, (after) ->
            depends.push {after:after,name:v.name,path:k,weight:v.weight,attached:v["hook-for"]}
          return
        else
          standalone.push {name:v.name,path:k,weight:v.weight,attached:v["hook-for"]}
          return

    modules =
      standalone:standalone
      depends:depends

    modules = JSON.stringify modules
    module_string = "module.exports = "+ util.inspect(modules)
    fs.writeFileSync self.modules,module_string
    defer.resolve "Registered modules successfully"
    defer.promise

module.exports = Sync
