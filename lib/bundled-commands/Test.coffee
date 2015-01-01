
"use strict"

karma = require "karma"
.server
Helpers = require "../util/Helpers"
helpers = new Helpers();
path = require "path"
shelljs = require "shelljs"

class Test

  run: (args) ->
    if args.watch
      commands = " --watch"
    else
      commands = ""
    task_runner_path = "node_modules/ng-task-runner"
    helpers.getConfig (err,data) ->
      if err
        helpers.trace err
        return
      else
        commands += " --test"
        shelljs.cd "#{data.project_root}/#{task_runner_path}"
        commands = "gulp build #{commands} --path #{data.project_root}"
        shelljs.exec commands, () ->
    return

module.exports = Test
