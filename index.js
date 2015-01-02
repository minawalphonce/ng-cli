#! /usr/bin/env node

var nomnom = require("nomnom");

var Helpers = require('./lib/util/Helpers');
var helpers = new Helpers();

var Sync = require('./lib/commands/sync');
var sync = new Sync();

var Generate = require('./lib/commands/generate');
var generate = new Generate();

var NewProject = require('./lib/commands/new');
var newProject = new NewProject();

var Hook = require('./lib/commands/hook');
var hook = new Hook();

var updateNotifier = require('update-notifier');
var pkg = require('./package.json');

updateNotifier({packageName: pkg.name, packageVersion: pkg.version,updateCheckInterval:1000}).notify();

nomnom.command('test')
.option('watch',{
  abbr: 'w',
  flag: true,
  help: "watch test files or changes and re run tests"
}).callback(function(opts) {
  var Test = require('./lib/bundled-commands/Test');
  var test = new Test();
  var parsed = helpers.parseCommand(opts);
  test.run(parsed);
}).help("run karma tests");

nomnom.command('new')
.option('name',{
  position: 1,
  required: true
}).callback(function(opts){
  var parsed = helpers.parseCommand(opts);
  newProject.run(parsed);
})
.help("Create new angular project name");

nomnom.command('generate')
.option('generator',{
  position: 1,
  list: true,
  required: true
}).callback(function(opts){
  var parsed = helpers.parseCommand(opts);
  generate.run(parsed);
})
.help("Generate blueprint using generators");


nomnom.command('hook')
.option('hook',{
  position: 1,
  required: true
}).callback(function(opts){
  var parsed = helpers.parseCommand(opts);
  hook.run(parsed);
})
.help("Run any hook using it's name");

nomnom.command('build')
.callback(function(opts){
  var Build = require('./lib/commands/build');
  var build = new Build();
  var parsed = helpers.parseCommand(opts);
  build.run(parsed);
})
.help("Build project files into dist folder");

nomnom.command('serve')
.callback(function(opts){
  var Build = require('./lib/commands/build');
  var build = new Build();
  var parsed = helpers.parseCommand(opts);
  build.run(parsed,true);
})
.help("Build, watch and run live server.");

nomnom.command('sync')
.option('type',{
  position: 1
})
.callback(function(opts){
  var parsed = helpers.parseCommand(opts);
  sync.run(parsed);
})
.help("Sync your project hooks");

nomnom.command('version')
.callback(function(opts){
  console.log("Version " + pkg.version);
})
.help("ng Version");

nomnom.parse();
