#
# Coded by Robin Costas del Moral
#
# This class is only meant to use with my bots, therefore its functionality 
# is to manage them, so it is quite limited outside its purpose
#
# This class only manages a pair of data, you can read and write on it
# and thats all. Extra methods for calling them however you want
#  
require 'singleton'
class MyResponses
  include Singleton
  attr_accessor :success_add, :success_remove, :greet, :repeated_add, :repeated_remove, :error, :not_asked, :borderias

  def initialize
    @success_add = ["Tremenda ejecucion, ya la he introducido","Con pocas ganas pero lo he añadido","Me caes bastante mal, pero aun asi lo he añadido"]
    @success_remove = ["Borrada correctamente, vaya basura estaba hecha"]
    @greet = ["Bienvenidos, os encontrais ante el mejor bot de telegram, aunque no dejais de ser unos puto inutiles \xF0\x9F\x98\x89 \n\n" + 
      "Voy a introducirme y a decir como funciona la basura esta: \xF0\x9F\x98\x82 \xF0\x9F\x98\x82\n" +
      "-> /add factura  (añadir una nueva factura)\n" +
      "-> /add compra   (añadir una nueva compra)\n" +
      "-> /add nota     (añadir una nueva nota)\n" +
      "-> /remove factura/compra/nota (quitar una factura/compra de la lista)\n" +
      "-> /list (mostrar TODO)\n\n" +
      "Y eso es todo, vamos a configurar esto y a ver si con vuestra inteligencia sois capaces de usarlo"]
    @repeated_add = ["Eso ya estaba guardado puto inutil"]
    @repeated_remove = ["Eso no estaba guardado retrasado"]
    @error = ["Que raro, con lo bien programado que estoy, y aun asi, ha ocurrido algun error"]
    @not_asked = ["Chaval que arca me has dao vieo", "No sabes quien soy? Soy chiquetete, el de pon bien lo que te pido", "Poca broma con el retraso que manejas", "Que le decimos a este, te coges el mensaje este finde y pones lo que te pido, tamos?","Introduce lo que pone, que soy muy picky con eso"]
    @borderias = ['Tus muertos', 'Inutil', 'No te quieren ni en tu casa', 'Tu puta madre pero de colegueo', 'Le caes bastante mal a todos', 
              'A decir verdad, e incluso teniendo en cuenta el clima economico actual, tu cara es una basura', "Menudo aborto estas hecho",
              "Te pareces al michel de motril" , "Jajajajaja que bocana has echao vieo" , "No te soporta ni Kiiro, y mira que le da igual la vida",
              "Ni tu mae te quiere" , "¿Te pasa algo?"]
  end

end