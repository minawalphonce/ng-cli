"use strict"

ControllerGenerator = require "../commands/generate/controller"
FilterGenerator = require "../commands/generate/filter"
DirectiveGenerator = require "../commands/generate/directive"
ServiceGenerator = require "../commands/generate/service"
FactoryGenerator = require "../commands/generate/factory"
InitializerGenerator = require "../commands/generate/initializer"
Helpers = require "../util/Helpers"
helpers = new Helpers()

class Generate
  run: (parsed) ->
   generator = parsed.generator
   if generator.length > 1
     identifier = generator[0]

     switch identifier
       when "controller"
         cg = new ControllerGenerator()
         cg.run parsed
         return
       when "filter"
         fg = new FilterGenerator()
         fg.run parsed
         return

       when "factory"
         fcg = new FactoryGenerator()
         fcg.run parsed
         return

       when "service"
         sg = new ServiceGenerator()
         sg.run parsed
         return

       when "initializer"
         ig = new InitializerGenerator()
         ig.run parsed
         return

       when "directive"
         dg = new DirectiveGenerator()
         dg.run parsed
         return
       else
         helpers.notify "error","Not a valid generator"
         return
   else
     helpers.notify "error","Not a valid generator"
     return

module.exports = Generate
