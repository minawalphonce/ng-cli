"use strict"

path = require "path"
Helpers = require "./helpers"
helpers = new Helpers()
fs = require "fs"
inquirer = require "inquirer"
shelljs = require "shelljs"
findup = require "findup"

###*
  @class BundledCommands
  @description All bundled commands are invoked from here.
###
class BundledCommands

  ###*
    @method addon
    @param args {Object} Command line arguments object
    @description Bundled command to create addon blueprint
  ###
  addon: (args) ->

    ###*
      Addon blueprint
    ###
    git_addon_path = "https://github.com/ngCli/ngcli-addon-blueprint.git"

    if args.name
      directory_path = path.join process.cwd(),args.name
      fs.exists directory_path, (exists) ->
        if exists
          helpers.lineup.log.error "#{args.name} already exists at #{directory_path}"
          process.exit 1
          return
        else
          helpers.clone git_addon_path,directory_path, () ->
            shelljs.cd directory_path
            shelljs.exec "rm -rf .git"
            shelljs.exec "npm install", () ->
              helpers.lineup.log.success "Created addon at path #{directory_path}"
              return
            return
          return
      return
    else
      helpers.lineup.log.error "enter addon name as ng addon <name>"
      return

  ###*
    @method newApp
    @param args {Object} Command line arguments object
    @description Bundled command to create new ngCli app
  ###
  newApp: (args) ->

    self = @

    ###*
      Inquirer object to prompts
    ###

    blueprints_question =
      type: "list"
      name: "blueprint",
      message: "Select project blueprint",
      choices: [
        {
          name:"Default template",
          value:"default"
        },
        {
          name:"Ui Router template",
          value:"ui-router"
        },
        {
          name:"Your own template from git",
          value:"git-pull"
        }
      ]

    ###*
      Git paths from templates name
    ###
    git_paths =
      "ui-router": "https://github.com/ngCli/ngcli-ui.router-blueprint.git"
      "default": "https://github.com/ngCli/ngcli-default-blueprint.git"

    ###*
      Question to ak if user choice is git-pull
    ###

    git_questions =
      type: "input",
      name: "git-path",
      message: "Enter git url to pull from",
      validate: (value) ->
        if value.trim().length > 0 then true else false

    ###*
      Looking if name of the project was passed
    ###
    if args.name
      directory_path = path.join process.cwd(),args.name
      ###*
        @note Checking for directory existence
      ###

      fs.exists directory_path, (exists) ->
        if exists
          helpers.lineup.log.error "#{args.name} already exists at #{directory_path}"
          process.exit 1
          return
        else
          ###*
            @note Asking project blueprint question
          ###
          inquirer.prompt blueprints_question,(answers) ->
            ###*
              @note If answer is git-pull , ask for git path
              and run clone on top of it
            ###
            if answers.blueprint is "git-pull"
              inquirer.prompt git_questions, (answers) ->
                ###*
                  @note Clone blueprint from custom path to project directory
                ###
                git_path = answers["git-path"]
                self.cloneProjectBluePrint git_path,directory_path
                return
              return
            else
              ###*
                @note Clone selected blueprint to project directory
              ###
              git_path = git_paths[answers.blueprint]
              self.cloneProjectBluePrint git_path,directory_path
              return
      return
    else
      helpers.lineup.log.error "enter app name as ng new <name>"
      return

  ###*
    @method cloneProjectBluePrint
    @param blueprint {String} Blueprint path to clone from git
    @param directory_path {String} Directory path to clone into
  ###
  cloneProjectBluePrint: (blueprint,directory_path) ->
    helpers.clone blueprint,directory_path, () ->
      shelljs.cd directory_path
      shelljs.exec "rm -rf .git"
      helpers.lineup.action.success "install", "installing using npm"
      shelljs.exec "npm install", () ->
        helpers.lineup.action.success "install", "installing using bower"
        shelljs.exec "bower install", () ->
          helpers.lineup.log.success "Created"
          helpers.lineup.highlight.start "NEXT STEPS"
          console.log "cd #{directory_path}"
          console.log "ng -h to list all command"
          helpers.lineup.highlight.end()
          return
        return
      return
    return

  ###*
    Simply run ng-task-runner inside node modules of app
  ###
  buildApp: () ->
    shelljs.cd process.cwd()
    ###*
      Make sure to use exec async by passing callback
      as sync version will eat the entire CPU
    ###
    shelljs.exec "node node_modules/ngcli-task-runner/index.js --build", (code,output) ->
      if code isnt 0
        helpers.lineup.log.error output


  ###*
    Install addons using npm , require it and run afterInstall function
    if exists
  ###
  installAddon: (args) ->
    findup process.cwd(),"package.json", (err,dir) ->
      if err
         helpers._terminate err
         return

      shelljs.cd dir
      shelljs.exec "npm install #{args.name} --save" , (code) ->
        if code is 0
          ###* All good ###
          ###*
            Set as ngAddon inside package json
          ###
          packageFile = require "#{dir}/package.json"
          packageFile["ng-addons"] = packageFile["ng-addons"] || {}
          packageFile["ng-addons"]["#{args.name}"] = args.name
          packageFile = JSON.stringify packageFile,null,2
          fs.writeFileSync "#{dir}/package.json",packageFile

          ###*
            Require installed addon and run after install method
          ###
          addon_path = path.join(dir,"node_modules/#{args.name}");
          getInstalledAddon = require addon_path
          if typeof getInstalledAddon.afterInstall is "function"
            getInstalledAddon.afterInstall();
            return
          return
        else
          helpers.lineup.log.error "npm install failed"
          return
      return
    return
  ###*
    Simply run ng-task-runner inside node modules of app
  ###
  serveApp: () ->
    shelljs.cd process.cwd()
    ###*
      Make sure to use exec async by passing callback
      as sync version will eat the entire CPU
    ###
    shelljs.exec "node node_modules/ngcli-task-runner/index.js --serve", (code,output) ->
      if code isnt 0
        helpers.lineup.log.error output

  ###*
    Run karma unit tests
  ###
  karmaStart: () ->
    shelljs.cd process.cwd()
    ###*
      Make sure to use exec async by passing callback
      as sync version will eat the entire CPU
    ###
    shelljs.exec "node node_modules/ngcli-task-runner/index.js --test", (code,output) ->
      if code isnt 0
        helpers.lineup.log.error output

module.exports = BundledCommands
