Helpers = require "./helpers"
helpers = new Helpers()

HookRunner = require "./hook-runner"
hookrunner = new HookRunner()

BundledCommands = require "./bundled-commands"
bundledcommands = new BundledCommands()

_ = require "lodash"
nomnom = require "nomnom"
path = require "path"

###*
  @class CommandsParser
  @description Parse commands and run supporting process on them.
###

class CommandsParser

  constructor: () ->

  ###*
    @method autoRun
    @param cb {function} Callback
    @description Parse and run dynamic commands registered by addons
  ###
  autoRun: (cb) ->
    self = @
    helpers._getAppAddons (err,addons) ->
      if err
        if cb
          cb()
        else
          helpers._terminate err
      else
        _.each addons.commands, (cmd) ->
          command = nomnom.command cmd.name
          _.each cmd.options, (value,key) ->
            options = {}
            options.required = value.required || false
            options.flag = value.flag || false
            if value.position
              options.position = value.position
            command.option key,options
            return
          command.callback (options) ->
            self.runHooks options,cmd.name
            return
          command.help cmd.description
          return
        if cb
          cb()
          return
        else
          nomnom.parse()
          return
        return
    return

  ###*
    @method runBundled
    @param cb {function} Callback
    @description Parse and run bundled commands
  ###
  runBundled: () ->
    ###
      All good . OK . Tested
    ###
    self = @
    nomnom.command 'new'
    .option 'name',
      required: true,
      position: 1,
      help: 'project name'
    .callback (options) ->
      bundledcommands.newApp options
      return
    .help 'Create new ngCli project'

    ###
      All good . OK . Tested
    ###
    self = @
    nomnom.command 'test'
    .option 'watch',
      flag: true,
      help: 'watch for changes in test files'
    .callback (options) ->
      bundledcommands.karmaStart options
      return
    .help 'Run karma unit tests'

    ###
      All good . OK . Tested
    ###
    nomnom.command 'install'
    .option 'name',
      required: true,
      position: 1,
      help: 'name of the hook you want to install'
    .callback (options) ->
      bundledcommands.installAddon options
      return
    .help 'Install ng hooks from npm'

    ###
      All good . OK . Tested
    ###
    nomnom.command 'build'
    .callback (options) ->
      bundledcommands.buildApp options
      return
    .help 'Build source files'

    ###
      All good . OK . Tested
    ###
    nomnom.command 'addon'
    .option 'name',
      required: true,
      position: 1,
      help: 'name of the addon you want to create'
    .callback (options) ->
      bundledcommands.addon options
      return
    .help 'Scaffold ng addon'

    ###
      All good . OK . Tested
    ###
    nomnom.command 'serve'
    .callback (options) ->
      bundledcommands.serveApp options
      return
    .help 'Add watcher to build source files on every change'


    ###
      All good . OK . Tested
    ###
    nomnom.command 'version'
    .callback (options) ->
      pck = require path.join __dirname,"../../package.json"
      console.log "Version #{pck.version}"
      return
    .help 'ngCli version'

    nomnom.parse()
    return

  ###*
    @method runHooks
    @param options {object} CLI arguments
    @param process_name {String} Command name
    @description Run hooks attached to passed command
  ###
  runHooks: (options,process_name) ->
    hookrunner.runFromProccess process_name
    .then (hooks) ->
      hookrunner.executeHooks options,hooks
    .then (output) ->
      console.log output
    .catch (err) ->
      console.log err
    return

module.exports = CommandsParser
