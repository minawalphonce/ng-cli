"use strict"

findup = require "findup"
fs = require "fs"
path = require "path"
Promise = require "bluebird"
_ = require "lodash"
nconf = require "nconf"
nconf.use "memory"
LineUp = require "lineup"
lineup = new LineUp()
Elapsed = require "elapsed"
colors = require "colors"

###*
# Helper methods to perform different tasks
# @class Helpers
# @constructor
###

class Helpers

  constructor: () ->
    ###*
      # @property config_file
      # @type {String} app config file
      # @final "ngconfig.json"
    ###
    @config_file = "ngconfig.json"
    ###*
      # @property tasks_file
      # @type {String} app build tasks file
      # @final "tasks.js"
    ###
    @tasks_file = "tasks.js"
    ###*
      # @property content_path
      # @type {String} path to content directory to save bundled and app specific hooks
    ###
    @content_path = path.join __dirname,"../../content"
    ###*
      # @property local_modules
      # @type {String} path to app specific hooks
    ###
    @local_modules = path.join @content_path,"modules.js"
    ###*
      # @property bundled_modules
      # @type {String} path to bundled hooks
    ###
    @bundled_modules = path.join @content_path,"bundled.js"
    ###*
      # @property project_path
      # @type {String} path to ngCli root
    ###
    @project_path = path.join __dirname,"../../"

  ###*
    # @method notify
    # @param type {String} type of notificiation can be [error,warning,success,info]
    # @param msg {String} Message to display
  ###
  notify: (type,msg) ->
    lineup.log[type] msg

  trace: (err) ->
    options = {}
    if err.trace
      options.trace = err.trace
      error = err.error
    else
      error = err;

    lineup.log.error error,options
    process.exit 1

  ###*
    # @method actionMessage
    # @param action {String} string to highlight in green
    # @param message {String} message left
  ###
  actionMessage: (action,message) ->
    message = "#{colors.green(action)} #{message}"
    console.log message

  ###*
    # @method getConfig
    # @return {callback} Returns callback with error or config object
  ###
  getConfig: (cb) ->
    self = @
    ###*
      # @description Using finup to find config file down from cwd
    ###
    findup process.cwd(), self.config_file, (err,dir) ->
      if err
        cb {error:err,trace:{code:"NGE801",message:"Unable to locate #{self.config_file} , make sure it is an ngCli project"}}
        return
      else
        config_path = path.join dir,self.config_file
        fs.readFile config_path, (err,content) ->
          if err
            cb {error:err,trace:{code:"NGE802",message:"Unable to locate #{self.config_file} , make sure it is an ngCli project"}}
            return
          else
            content = content.toString()
            try
              contentObj = JSON.parse(content)
              returnObj =
                config:contentObj
                project_root:dir
              cb null,returnObj
              return
            catch e
              cb {error:e,trace:{code:"NGE803",message:"Unable to parse #{self.config_file} , corrupt json file"}}
              return
        return
    return

   ###*
     # @method getTasksFile
     # @return {callback} Returns callback with error or build tasks file path
   ###
   getTasksFile: (cb) ->
     self = @
     findup process.cwd(), self.tasks_file, (err,dir) ->
       if err
         cb {error:err,trace:{code:"NGE811",message:"Unable to locate #{self.tasks_file} , make sure it is an ngCli project or run npm install to install dependencies"}}
         return
       else
         file_path = path.join dir,self.tasks_file
         cb null, file_path
     return

   ###*
    # @method getTasksFile
    # @private
    # @param model {Object} modules object to loop from
    # @param key {String} key to look for
    # @param attached_with {String} find hook is attached with which proccess
    # @return {object} Returns filtered model object
   ###
   queryDependent: (model,key,attached_with) ->
     _.filter model, (val) ->
       val.after == key && val.attached == attached_with

   ###*
    # @method run
    # @param command {String} which command is getting executed
    # @param hooks_to_proccess {Object} list of hooks attached with executed command/process
    # @param config {Object} ngconfig object
    # @param args {Object} Command arguments
    # @description execute hooks configured with executed command/process
   ###
   run: (command,hooks_to_proccess,config,args,cb) ->
     x = 0
     hooks_methods = _.map hooks_to_proccess , (val) ->
       val._init

     started_at = new Date()

     Promise.reduce hooks_methods, (output,process) ->
       if typeof output is "string"
         lineup.log.success output
       if typeof output is "function"
         output = null
       console.log "\n" + colors.bold.underline "Executing #{hooks_to_proccess[x].name}"
       x++
       process = require(process).init
       process output,config,args,nconf
     , 0
     .then (final_output) ->
       elapsedTime = new Elapsed started_at,new Date()
       time_spent = elapsedTime.optimal || elapsedTime.milliSeconds + " milliseconds"
       lineup.log.success final_output
       console.log "Time spent #{time_spent}"
       if typeof cb == "function"
         cb final_output
         return
       else
         process.exit 0
         return
       return
     .catch (err) ->
       lineup.log.error err
       process.exit 1
       return
     return

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

   ###*
    # @method parseCommand
    # @param command Raw command to parse
    # @param process runned as which process
    # @example ng new sampleProject
        new is passed 2nd argument
        ng new sampleProject is passed 1st argument
   ###
   parseCommand: (command,process) ->
     parsed_opts = {}
     if command[process]
       parsed_opts.command = command[process]
       delete command[process]

     if command["--opts"]
       options = command["--opts"].split " "
       delete command["--opts"]
       _.each options, (values) ->
         kv_pairs = values.split ":"
         if _.size(kv_pairs) > 0
           parsed_opts[kv_pairs[0]] = kv_pairs[1]
           return
         else
           parsed_opts[kv_pairs[0]] = true
           return

      return _.extend(parsed_opts,command)

   ###*
    # @method fetchHookMethod
    # @param hook_name Name of the hook
    # @description fetches and returns hook init method with it's name
   ###

   fetchHookMethod: (hook_name) ->
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

      combined_modules = _.flatten(modules.standalone).concat(_.flatten(modules.depends))
      return _.find(_.compact(combined_modules),{name:hook_name});

   ###*
    # @method sortModules
    # @param attached_with {String} hook-for identifier
    # @return {promise} List of sorted hooks
    # @description sort and return hooks ready to be executed
   ###
   sortModules: (attached_with) ->
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

module.exports = Helpers
