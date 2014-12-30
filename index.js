#! /usr/bin/env node

var nut = require('nut-cli');

var Helpers = require('./lib/util/Helpers');
var helpers = new Helpers();


var Tasks = require('./lib/bundled-commands/Tasks');
var tasks = new Tasks();

var Sync = require('./lib/commands/sync');
var sync = new Sync();

var NewProject = require('./lib/commands/new');
var newProject = new NewProject();

var ControllerGenerateCommand = require('./lib/commands/generate/controller');
var cg = new ControllerGenerateCommand();

var Build = require('./lib/commands/build');
var build = new Build();

var Hook = require('./lib/commands/hook');
var hook = new Hook();


nut.bootCommand('ngCli');

nut.addCommand('sync','[option:String]','Which modules to sync can be all or bundled');
nut.addCommand('new','[project_name:String]','Enter new project name');
nut.addCommand('build',false,'Build project');
nut.addCommand('hook','[name:String]','Hook you want to run manually');
nut.addCommand('generate','[generator:String]','Name of generator you want to invoke');

nut.addCommandOptions('sync','--opts','[options:String]','number of options to pass with sync command');
nut.addCommandOptions('new','--opts','[options:String]','number of options to pass with new command');
nut.addCommandOptions('build','--opts','[options:String]','number of options to pass with build command');
nut.addCommandOptions('hook','--opts','[options:String]','number of options to pass with hook command');
nut.addCommandOptions('generate','--opts','[options:String]','number of options to pass with generate command');

var commands = nut.parse();

if(commands.sync){
  var parsed = helpers.parseCommand(commands,'sync');
  sync.run(parsed);
}
if(commands.new){
  var parsed = helpers.parseCommand(commands,'new');
  newProject.run(parsed);
}
if(commands.generate){
  var parsed = helpers.parseCommand(commands,'generate');
  cg.run(parsed);
}
if(commands.hook){
  var parsed = helpers.parseCommand(commands,'hook');
  hook.run(parsed);
}

if(commands.build){
  var parsed = helpers.parseCommand(commands,'build');
  build.run(parsed);
}
