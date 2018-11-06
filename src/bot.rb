require 'telegrammer'
require_relative '../lib/my_file'
require_relative '../lib/my_pair'
require_relative '../lib/my_map'
require_relative '../lib/my_utils'
require_relative '../lib/my_responses'

#
# Coded by Robin Costas del Moral & Antonio Jaimez Jimenez
#
# This bot is meant to manage the payments on a flat
# This way, you do an initial configuration of number of flatmates and
# administrator name. Once done, you can add/remove payments and set who
# has already paid and so on
#  

# Creamos el bot
token = URI.encode(MyFile.new("db/.TOKEN").get_item(0).chop)
pacasa_bot = MyBot.new(token)

# We will have a map for each type of payment, PONER EL TOTAL NO EL DIVIDIDO
# facturas: agua, luz, internet
# compras: compras por los miembros del piso
# notas: Anotaciones de cualquier cosa
facturas  = MyMap.new()
compras   = MyMap.new()
notas     = MyMap.new()
members   = MyMap.new()

# Various variables to store info about the users
initialized = false
current_chat = nil
num_members = 0

# We do it with begin so we can rescue needed data in case of exeption(^C)
begin
  while(!initialized)
    message = pacasa_bot.await_message
    pacasa_bot.current_chat = message.chat_id
    case message.text
      # When /start we introduce the bot and ask for the flat members information
      when /\/start.*/
        # We print the /start message
        pacasa_bot.send_message(responses.greet[0])
        # We ask for number of members
        pacasa_bot.send_message("Cuantas desgracias forman el piso @#{message.from.username}", pacasa_bot.get_force_reply)
        
        # We wont stop asking until the user enters a valid value
        continue = true
        while(continue)
          begin
            num_members = Integer(pacasa_bot.await_response(message.from.username))
            continue = false
          rescue ArgumentError
            pacasa_bot.send_message(responses.not_asked.sample)
          end
        end

        # Now we get the @username and first name
        pacasa_bot.send_message("Ahora hablad por turnos para que me quede con vuestros caretos, tened en cuenta que el primero en hablar sera el administrador")
        for i in 1..num_members
          pacasa_bot.send_message("Makina numero #{i}:")
          response = pacasa_bot.await_message
          if(members.find(response.from.username)==-1)
            members.add_item(response.from.username, response.from.first_name)
          else
            i -= 1
          end
        end

    end 
  end

  while(true)
    
  end

rescue SignalException => e   ################################################################################################################### FIN
  puts "\nSIGNAL => #{e} \nEl bot se ha parado, realizando tareas de mantenimiento...\n"
  if(initialized)
    puts "Guardando ID del chat para posterior uso\n"
    puts "Hecho\n"
  end
  puts "Cerrando descriptores de ficheros"
  puts "Hecho\n"
  puts "Guardando cambios realizadas en la base de datos"
  puts "Hecho, tareas finalizadas, nos vemos\n"
end
  
