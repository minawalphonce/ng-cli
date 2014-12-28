var nut = require('nut-cli');
var Sync = require('./lib/bundled-commands/Sync');
var Promise = require('bluebird');

var RunCommand = require('./lib/commands/new');
var r = new RunCommand();

var ControllerGenerateCommand = require('./lib/commands/generate/controller');
var cg = new ControllerGenerateCommand();


var Tasks = require('./lib/bundled-commands/Tasks');
var tasks = new Tasks();

nut.bootCommand('ngCli');
nut.addCommand('sync',false,'Enter repo name');
nut.addCommand('new','[project_name:String]','Enter new project name');
nut.addCommand('build',false,'Build project');
nut.addCommand('generate','[what:String]','Build project');

var commands = nut.parse();

if(commands.sync){
  var sync = new Sync();
  sync.init('bundled')
  // sync.write('bundled')
  .then(function(data){
    return sync.fetchModules(data);
  }).then(function(data){
    return sync.registerModules(data);
  }).then(function(success){
    console.log(success);
  }).catch(function(err){
    console.log(err);
  });
}
if(commands.new){
  r.run(commands);
}
if(commands.generate){
  cg.run(commands);
}
if(commands.build){
  tasks.parse().then(function(){
    return tasks.runTasks();
  }).then(function(success){
    console.log(success);
    tasks.registerWatchers();
  }).catch(function(err){
    console.log(err);
  });
}
