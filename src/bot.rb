require 'telegram/bot'
require_relative '../lib/my_file'
require_relative '../lib/my_pair'
require_relative '../lib/my_map'
#
# Coded by Robin Costas del Moral
#
# This bot is meant to manage the payments on a flat
# This way, you do an initial configuration of number of flatmates and
# administrator name. Once done, you can add/remove payments and set who
# has already paid and so on
#  
# Await response from a certain user, it returns the response

#! Convendria crear un fichero my_utils y meter todas las funciones chorra estas
def await_response(user, pacasa_bot)
  response = false
  while(!response)
    pacasa_bot.fetch_updates do |message|
      if (message.from.id == user)
        response = true
        return message
      end
    end
  end
end

def await_int(user, pacasa_bot)
  stop = false
  while(!stop)
    pacasa_bot.fetch_updates do |message|
      begin
        if (message.from.id == user)
          stop = true
          ret = Integer(message.text)
          return ret
            
        end
      rescue ArgumentError
        # If they dont enter an Int, we ask for the information again
        pacasa_bot.api.send_message(chat_id: current_chat, text: not_asked.sample)
        stop = false
      end
    end
  end
end

def await_float(user, pacasa_bot)
  stop = false
  while(!stop)
    pacasa_bot.fetch_updates do |message|
      begin
        if (message.from.id == user)
          stop = true
          ret = Float(message.text)
          return ret
            
        end
      rescue ArgumentError
        # If they dont enter an Int, we ask for the information again
        pacasa_bot.api.send_message(chat_id: current_chat, text: not_asked.sample)
        stop = false
      end
    end
  end
end


# Arrays that contain different responses so it isnt too repetitive
success_add = ["Tremenda ejecucion, ya la he introducido","Con pocas ganas pero lo he añadido","Me caes bastante mal, pero aun asi lo he añadido"]
success_remove = ["Borrada correctamente, vaya basura estaba hecha"]
greet = []
repeated_add = ["Eso ya estaba guardado puto inutil"]
repeated_remove = ["Eso no estaba guardado retrasado"]
error = ["Que raro, con lo bien programado que estoy, y aun asi, ha ocurrido algun error"]
not_asked = ["Me cago en la puta, no sabes ni leer, ponlo BIEN", "Joder chaval, PON LO QUE TE PIDO RETRASADO", "Venga ahora fuera coñas, ponlo bien", "Que le decimos a este, te coges el mensaje este finde y pones lo que te pido, tamos?"]
borderias = ['Tus muertos', 'Inutil', 'No te quieren ni en tu casa', 'Tu puta madre pero de colegueo', 'Le caes bastante mal a todos', 
            'A decir verdad, e incluso teniendo en cuenta el clima economico actual, tu cara es una basura', "Menudo aborto estas hecho",
            "Te pareces al michel de motril" , "Jajajajaja que bocana has echao vieo" , "No te soporta ni Kiiro, y mira que le da igual la vida",
            "Ni tu mae te quiere" , "¿Te pasa algo?"]

token = URI.encode(MyFile.new("db/.TOKEN").get_item(0).chop)

# Variables for chat and bot managing
pacasa_bot = Telegram::Bot::Client.new(token)
initialized = false
current_chat = nil

# Variables for time control
timer = nil
current_time = nil

# We will have a map for each type of payment, PONER EL TOTAL NO EL DIVIDIDO
# facturas: agua, luz, internet
# compras: compras por los miembros del piso
# notas: Anotaciones de cualquier cosa
facturas  = MyMap.new("db/facturas.txt")
compras   = MyMap.new("db/compras.txt")
notas     = MyMap.new("db/notas.txt")

# Various variables to store info about the users
num_members = 0
members = MyMap.new("db/users.txt")


# Count number of times str appears in target
def count_em(str, target)
  target.chars.uniq.map { |c| str.count(c)/target.count(c) }.min
end


# We do it with begin so we can rescue needed data in case of exeption(^C)
begin
  #if(File.exists?("db/.ID"))
  #  initialized = true
  #  tmpID = MyFile.new("db/.ID")
  #  current_chat = tmpID.get_item(0)
  #  tmpID.delete
  #end
  while(!initialized)
    pacasa_bot.fetch_updates do |message|
      case message.text
        # When /start we introduce the bot and ask for the flat members information
        when /\/start.*/
          initialized = true
          current_chat = message.chat.id
          pacasa_bot.api.send_message(chat_id: message.chat.id, text: "Bienvenidos, os encontrais ante el mejor bot de telegram, aunque no dejais de ser unos puto inutiles \xF0\x9F\x98\x89 \n\n" + 
                                                                      "Voy a introducirme y a decir como funciona la basura esta: \xF0\x9F\x98\x82 \xF0\x9F\x98\x82\n" +
                                                                      "-> /add factura  (añadir una nueva factura)\n" +
                                                                      "-> /add compra   (añadir una nueva compra)\n" +
                                                                      "-> /add nota     (añadir una nueva nota)\n" +
                                                                      "-> /remove factura/compra/nota (quitar una factura/compra de la lista)\n" +
                                                                      "-> /list (mostrar TODO)\n\n" +
                                                                      "Y eso es todo, vamos a configurar esto y a ver si con vuestra inteligencia sois capaces de usarlo")
          pacasa_bot.api.send_message(chat_id: current_chat, text: "Cuantas desgracias habitan el piso?")
          
          # We only want the response from the one who /started the bot
          user = message.from.id
          stop = false
          num_members = await_int(user, pacasa_bot)
          pacasa_bot.api.send_message(chat_id: current_chat, text: "Muy bien, sois #{num_members}, ahora hablad por turnos\xF0\x9F\x98\xA9")
          i = 0
          # Now each member has to talk in order to get his/her ID + Name association
          while(i<num_members)
            i += 1
            pacasa_bot.api.send_message(chat_id: current_chat, text: "Que hable el makina numero #{i}:")
            pacasa_bot.fetch_updates do |message|
                members.add_item(message.from.id, message.from.first_name)
            end
            pacasa_bot.api.send_message(chat_id: current_chat, text: "Apunto a #{members.get_values(message.from.first_name).to_s.gsub("[\"","").gsub("\"]","")}")
 
          end
          pacasa_bot.api.send_message(chat_id: current_chat, text: "Todo listo, ya podeis empezar la locura")

      end
    end
  end

  while(true)

    pacasa_bot.fetch_updates do |message|
      case message.text
        # Random borderia
        when /\/borderia/
          pacasa_bot.api.send_message(chat_id: current_chat, text: borderias.sample)

        # We list the user whatever he/she specifies ########################################################################################################## LIST
        when /\/list.*/
          user = message.from
          from = message.from.id
          action = nil
          name = nil
          quantity = nil

          action = message.text
          action.slice!("/list")

          case(action)
            when ''
              # Mostrariamos todo
            when /facturas/
              action = "facturas"
              # WIP
            when /compras/
              action = "compras"
              #! Mostrariamos para cada compra el nombre(campo key del mapa) quien la ha puesto(en el mapa el campo value(el cual es un array, el elemento en la segunda posicion)) y la cantidad total + cada uno
            when /notas/
              action = "notas"
              #! Comentario temporal: Mostrariamos quien la ha puesto(key) y el contenido(value)
            else
              pacasa_bot.api.send_message(chat_id: current_chat, text: "Puto inutil, se usa asi: /list (factura/compra/nota)")
          end

          puts "antes del case"

          # Now we get the parameters from the user and we create the item in our maps
          case(action)
            when /facturas/
              i = 0
              text = "Por suerte, no hay ninguna factura todavia"
              while(i<facturas.size)
                text = "---#{facturas.get_item(i).first}---\n Cantidad Total->#{facturas.get_item(i).second[0]} \n 
                Cada Uno->#{(facturas.get_item(i).second[0])/num_members}\n Ha pagado:"
                if(facturas.get_item(i).second.size > 1)
                  first = true
                  for p in facturas.get_item(i).second
                    if(first)
                      first = false
                    else
                      text += members.get_value(p)
                    end
                  end
                else
                  text += "Nadie xddd\n"
                end
                i+=1
              end
              pacasa_bot.api.send_message(chat_id: current_chat, text: text)

            when /compras/
              ##pacasa_bot.api.send_message(chat_id: current_chat, text: "Not Implemented")
              i = 0
              text = "No le debemos dinero a nadie gracias al señor"
              while(i < compras.size)
                text = "---#{compras.get_item(i).first}---\n Total->#{compras.get_item(i).second[0]} \n Cada uno ->#{(compras.get_item(i).second[0])/num_members}\n
                Ha pagado ya:  "
                if(compras.get_item(i).second.size > 1)
                  first = true
                  for p in compras.get_item(i).second
                    if(first)
                      first = false
                    else
                      text += members.get_value(p)
                    end
                  end
                else
                  text += "Ni cristofer chaval\n"
                end
                i+=1
              end
              pacasa_bot.api.send_message(chat_id: current_chat, text: text)
            when /notas/
              ##pacasa_bot.api.send_message(chat_id: current_chat, text: "Not Implemented")
              i = 0
              text = "Menos mal que nadie ha puesto ninguna tonteria en una nota"
              while(i < notas.size)
                user = notas.get_item(i).first
                text= "*******NOTA DE #{user}*********\n"
                text += "#{notas.get_item(i).second} \n"
                text += "#{borderias.sample} #{user} "
              end
              pacasa_bot.api.send_message(chat_id: current_chat, text: text)
            else
              puts "Error, action es -#{action}-"
            end
        
        # We add to our db whatever the user specifies ################################################################################################### ADD
        when /\/add.*/ 
          args = count_em(' ', message.text)
          user = message.from
          from = message.from.id
          name = nil
          quantity = nil

          action = message.text
          action.slice!("/add")

          # If no argument is given
          case(action)
          when ''
            pacasa_bot.api.send_message(chat_id: current_chat, text: "Que es lo que quieres aniadir? (factura/compra/nota)")
            response = await_response(user.id, pacasa_bot)
            
            case(response.text.downcase)
              when /factura/
                action = "factura"
              when /compra/
                action = "compra"
              when /nota/
                action = "nota"
              end
          
          # If 1 argument is given
          when /factura/
            action = "factura"
          when /compra/
            action = "compra"
          when /nota/
            action = "nota"
          else
            pacasa_bot.api.send_message(chat_id: current_chat, text: "Puto inutil, se usa asi: /add (factura/compra/nota)")
          end

          # Now we get the parameters from the user and we create the item in our maps
          case(action)
            when "factura"
              pacasa_bot.api.send_message(chat_id: current_chat, text: "Dime el nombre de la factura")
              response = await_response(user.id, pacasa_bot)
              name = response.text

              pacasa_bot.api.send_message(chat_id: current_chat, text: "Ahora dime cuanto no te va a pagar Robin(pon el total)")
              quantity = await_float(user.id, pacasa_bot)

              facturas.add_item(name, quantity)

            when "compra"
              pacasa_bot.api.send_message(chat_id: current_chat, text: "Dime el nombre de la compra")
              response = await_response(message.from.id)
              name = response.text

              pacasa_bot.api.send_message(chat_id: current_chat, text: "Ahora dime cuanto acabas de perder porque xd que te paga alguien(pon el total)")
              quantity = await_float(user.id, pacasa_bot)

              compras.add_item(name, user.first_name)
              compras.add_value(name, quantity)

            when "nota"
              pacasa_bot.api.send_message(chat_id: current_chat, text: "Dime el nombre de la nota")
              response = await_response(message.from.id)
              name = response.text

              pacasa_bot.api.send_message(chat_id: current_chat, text: "Ahora dime el contenido de la nota:")
              quantity = await_response(user.id, pacasa_bot)

              notas.add_item(name, quantity)
            end

        else
          pacasa_bot.api.send_message(chat_id: current_chat, text: "No se que me acabas de decir, #{borderias.sample.downcase}")
      end
    end
  end

rescue SignalException => e   ################################################################################################################### FIN
  puts "\nSIGNAL => #{e} \nEl bot se ha parado, realizando tareas de mantenimiento...\n"
  if(initialized)
    puts "Guardando ID del chat para posterior uso\n"
      #tmp = File.new("ID","w+")
      #tmp.puts(current_chat)
      #tmp.close
    puts "Hecho\n"
  end
  puts "Cerrando descriptores de ficheros"
  puts "Hecho\n"
  puts "Guardando cambios realizadas en la base de datos"
    #facturas.write_to_db
    #compras.write_to_db
    #notas.write_to_db
  puts "Hecho, tareas finalizadas, nos vemos\n"
end
  
