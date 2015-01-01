
controllerGenerator = require "../commands/generate/controller"
filterGenerator = require "../commands/generate/filter"
directiveGenerator = require "../commands/generate/directive"
serviceGenerator = require "../commands/generate/service"
factoryGenerator = require "../commands/generate/factory"
initializerGenerator = require "../commands/generate/initializer"
Helpers = require "../util/Helpers"
helpers = new Helpers()

class Generate
  run: (parsed) ->
   generator = parsed.generator
   if generator.length > 1
     identifier = generator[0]

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
         helpers.notify "error","Not a valid generator"
         return
   else
     helpers.notify "error","Not a valid generator"
     return

module.exports = Generate
