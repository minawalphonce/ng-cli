
controllerGenerator = require "../commands/generate/controller"
filterGenerator = require "../commands/generate/filter"
directiveGenerator = require "../commands/generate/directive"
serviceGenerator = require "../commands/generate/service"
factoryGenerator = require "../commands/generate/factory"
initializerGenerator = require "../commands/generate/initializer"

class Generate
  run: (parsed) ->
   command = parsed.command.split ":"
   if command.length > 0
     identifier = command[0]

     switch identifier
       when "controller"
         cg = new controllerGenerator()
         cg.run parsed
         return
       when "filter"
         fg = new filterGenerator()
         fg.run parsed
         return

       when "factory"
         fcg = new factoryGenerator()
         fcg.run parsed
         return

       when "service"
         sg = new serviceGenerator()
         sg.run parsed
         return

       when "initializer"
         ig = new initializerGenerator()
         ig.run parsed
         return

       when "directive"
         dg = new directiveGenerator()
         dg.run parsed
         return
       else
         @.notify "error","Not a valid generator"
         return
   else
     @.notify "error","Not a valid generator"
     return

module.exports = Generate
