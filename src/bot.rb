require 'telegrammer'
require_relative '../lib/my_pair'
require_relative '../lib/my_map'
require_relative '../lib/my_bot'
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
token = URI.encode(File.open('db/.TOKEN', &:readline).chop)
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

# Shitty variables
spain = "\xF0\x9F\x87\xAA\xF0\x9F\x87\xB8"

# Bot responses
responses = MyResponses.instance

# We do it with begin so we can rescue needed data in case of exeption(^C)
begin
  while(!initialized)
    message = pacasa_bot.await_message
    pacasa_bot.current_chat = message.chat.id
    case message.text
      # When /start we introduce the bot and ask for the flat members information
      when /\/start.*/
        # We print the /start message
        pacasa_bot.send_message(responses.greet[0])
        # We ask for number of members
        pacasa_bot.send_message("Cuantas desgracias forman el piso @#{message.from.username}", pacasa_bot.get_force_reply(true))
        
        # We wont stop asking until the user enters a valid value
        continue = true
        while(continue)
          begin
            num_members = Integer(pacasa_bot.await_message(message.from.username).text)
            continue = false
          rescue ArgumentError
            pacasa_bot.send_message(responses.not_asked.sample)
          end
        end

        # Now we get the @username and first name
        pacasa_bot.send_message("Ahora hablad por turnos para que me quede con vuestros caretos, tened en cuenta que el primero en hablar sera el administrador")
        i = 0
        while i<num_members
          pacasa_bot.send_message("Makina numero #{i+1}:", pacasa_bot.get_force_reply(false))
          response = pacasa_bot.await_message
          if(members.find(response.from.username)==-1)
            members.add_item(response.from.username, response.from.first_name)
            pacasa_bot.send_message("Apunto al inutil de #{response.from.first_name}")
            i+=1
          else
            pacasa_bot.send_message("Callate inutil, que tu ya estas")
          end
        end
        initialized = true

    end 
  end
  puts "a exarlo to abajo"
  while(true)
    message = pacasa_bot.await_message
    pacasa_bot.current_chat = message.chat.id
    puts "hay mensaje, #{message.text}"
    case message.text
      when /\/pacasa/
        pacasa_bot.send_message("#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}\n"+
                                "#{spain}#{spain}#{spain}VIVA ESPAÑA COÑO#{spain}#{spain}#{spain}\n"+
                                "#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}")
        himno = File.open("media/audios/PACASAA.ogg")
        pacasa_bot.send_audio(himno)

    end
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
  
