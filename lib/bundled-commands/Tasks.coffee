"use strict"

Helpers = require "../util/Helpers"
helpers = new Helpers()
path = require "path"
Promise = require "bluebird"
_ = require "lodash"
shelljs = require "shelljs"
Gaze = require "gaze"
       .Gaze
minimatch = require "minimatch"
browserSync = require "browser-sync"

###*
  # Class to initiate watcher and run build tasks using ng-task-runner
  # @class Tasks
  # @constructor
###

class Tasks

  constructor: () ->
    @watchers = {}
    @identifiers = {}
    @app_root = ""
    @task_runner_path = "node_modules/ng-task-runner"
    @live_reload = ""

  ###*
    # @method parse
    # @description parse list of tasks written inside ng-task-runner/tasks.js file
    # @return {promise} Returns promise string with success or error
  ###
  parse: () ->
    self = @
    defer = Promise.defer()
    helpers.getConfig (err,config) ->
      if err
        defer.reject err
        return
      else
        self.app_root = config.project_root
        file = "#{config.project_root}/#{self.task_runner_path}/tasks.js"
        console.log file
        tasks = require(file)()
        _.each tasks, (values,keys) ->
          self.identifiers[keys] = values["task-identifier"]
          if values.watch
            self.watchers[keys] = {minimatch:values.watch.files,ignores:values.watch.ignore || {} }
            return
        defer.resolve "parsed tasks"
    defer.promise

  ###*
    # @method registerWatchers
    # @description register all required watchers to watch for file changes and run parsed tasks
    # @requires Gaze
  ###
  registerWatchers: () ->
    self = @
    files_to_watch = []
    _.each self.watchers, (values) ->
      files_to_watch = files_to_watch.concat values.minimatch
      return

    gaze = new Gaze files_to_watch,{ cwd: @app_root , matchEmptyDirs:true }
    gaze.on "all", (event,filepath) ->
      self.decideTasks filepath


  ###*
    # @method decideTasks
    # @private
    # @param changedFile {String} path to file changed
    # @description Decide which tasks to run depending upon file changed
  ###
  decideTasks: (changedFile) ->
    commands = ""
    self = @

    _.each self.watchers, (values,keys) ->
      keysFetched = false
      _.each values.minimatch, (pattern) ->
        pattern = pattern.split "/"
        pattern_ext = pattern[pattern.length-1]

        ignore_files = _.map values.ignores, (igf) ->
          path.join self.app_root,igf

        if minimatch(changedFile,pattern_ext,{matchBase:true}) && not _.contains(ignore_files,changedFile)
          if not keysFetched
            commands += " "+self.identifiers[keys]
            keysFetched = true
            return

    if _.size(commands) > 0
      shelljs.cd "#{self.app_root}/#{self.task_runner_path}"
      commands = "gulp build #{commands} --path #{self.app_root}"
      shelljs.exec commands, (status) ->
        self.reloadServer()
        console.log status
        ### @todo Show successfull build message ###
        return
      return

  ###*
    # @method runTasks
    # @description Run all tasks in one go for one time
  ###
  runTasks: () ->
    self = @
    defer = Promise.defer()
    commands = ""

    helpers.actionMessage "build","started build process..."

    _.each self.identifiers, (v) ->
      commands += " "+v
      return

    if _.size(commands) > 0
      shelljs.cd "#{self.app_root}/#{self.task_runner_path}"
      commands = "gulp build #{commands} --path #{self.app_root}"
      shelljs.exec commands, (status) ->
        if status is 0
          helpers.actionMessage "build","Build completed"
          defer.resolve "build completed"
          return
        else
          defer.reject "Error running build"
          return
    else
      defer.resolve "No commands to run"
      return
    defer.promise

  ###*
    # @method checkAndStartServer
    # @description fetches config and start a server
  ###
  checkAndStartServer: () ->
    self = @
    helpers.getConfig (err,config) ->
      if err
        helpers.notify "error",err
        process.exit 1
        return
      else
        if config.config.run_server
          self.live_reload = config.config.live_reload
          helpers.actionMessage "server","Invoking server ..."
          self.startServer config
          return
        return
    return

  ###*
    # @method startServer
    # @param config {Object} ngconfig object
  ###
  startServer: (config) ->
    serverConfig =
      server:
        baseDir: config.project_root
      host:config.config.host
      port: config.config.port
      notify: false

    browserSync serverConfig, (err) ->
      if err
        console.log err
        # helpers.notify "error",err
        return
      else
        helpers.notify "success","Server started and running on #{config.config.host}:#{config.config.port}"
        return
    return

  ###*
    # @method reloadServer
    # @description Reloads server on file change
  ###
  reloadServer: () ->
    if @.live_reload
      browserSync.reload()
      return

module.exports = Tasks
