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
admin = ""

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
          if(i==0)
            admin = response.from.username
          end
          
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
  
  while(true)
    message = pacasa_bot.await_message
    pacasa_bot.current_chat = message.chat.id
    #puts "hay mensaje, #{message.text}"
    case message.text
      when /\/pacasa/
        pacasa_bot.send_message("#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}\n"+
                                "#{spain}#{spain}#{spain}VIVA ESPAÑA COÑO#{spain}#{spain}#{spain}\n"+
                                "#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}#{spain}")
        himno = File.open("media/audios/PACASAA.ogg")
        pacasa_bot.send_audio(himno)

      ######################################################################################################################## /add
      when /\/add/
        message.text.slice!("/add ")
        action = message.text

        case action
          ############################################# factura
          when /factura/
            if(message.from.username == admin)
              pacasa_bot.send_message("Dime el nombre de la factura @#{message.from.username}", pacasa_bot.get_force_reply(true))
              name = pacasa_bot.await_message(message.from.username).text
              pacasa_bot.send_message("Poca broma con #{name}, @#{message.from.username} cuanto es la basura esta?",pacasa_bot.get_force_reply(true))
              quantity = 0
              continue = true
              while(continue)
                begin
                  quantity = Float(pacasa_bot.await_message(message.from.username).text)
                  continue = false
                rescue ArgumentError
                  pacasa_bot.send_message(responses.not_asked.sample)
                end
              end
              pacasa_bot.send_message("Vamos a revisar los datos que seguro que te has equivocado:\n"+
                                      "Factura: #{name}\n"+
                                      "Cantidad: #{quantity}\n"+
                                      "Cada uno: #{quantity/num_members}\n"+
                                      "Son correctos los datos @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
              response = pacasa_bot.await_message(message.from.username).text
              if(response == 'SI')
                pacasa_bot.send_message("Pues tendre que introducir la factura de mierda esa, #{responses.borderias.sample}")
                facturas.add_item(name, quantity)

              else
                pacasa_bot.send_message("Si esque estaba clarisimo que no servias para nada, #{responses.borderias.sample}")
              end
            else
              pacasa_bot.send_message("Solo puede introducir facturas el admin del grupo (Por desgracia @#{admin})")
            end
            
          ############################################# compra
          when /compra/
            pacasa_bot.send_message("Dime el nombre de la compra @#{message.from.username}", pacasa_bot.get_force_reply(true))
            name = pacasa_bot.await_message(message.from.username).text
            pacasa_bot.send_message("Si te paga #{name} alguien milagro, cuanto dinero acabas de perder @#{message.from.username}?",pacasa_bot.get_force_reply(true))
            quantity = 0
            continue = true
            while(continue)
              begin
                quantity = Float(pacasa_bot.await_message(message.from.username).text)
                continue = false
              rescue ArgumentError
                pacasa_bot.send_message(responses.not_asked.sample)
              end
            end
            pacasa_bot.send_message("Vamos a revisar los datos que seguro que te has equivocado:\n"+
                                    "Nombre: #{name}\n"+
                                    "Cantidad: #{quantity}\n"+
                                    "Cada uno: #{quantity/num_members}\n"+
                                    "Son correctos los datos @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
            response = pacasa_bot.await_message(message.from.username).text
            if(response == 'SI')
              pacasa_bot.send_message("Pues nada habra que guardarla, #{responses.borderias.sample}")
              compras.add_item(name, quantity)
              compras.add_value(name, message.from.username)

            else
              pacasa_bot.send_message("Como si supieras hacer algo, #{responses.borderias.sample}")
            end

          ############################################# nota
          when /nota/
            pacasa_bot.send_message("@#{message.from.username} dime el titulillo de la notilla", pacasa_bot.get_force_reply(true))
            name = pacasa_bot.await_message(message.from.username).text
            pacasa_bot.send_message("Y que contenido tiene la basura de #{name}, @#{message.from.username}?",pacasa_bot.get_force_reply(true))

            quantity = pacasa_bot.await_message(message.from.username).text

            pacasa_bot.send_message("Vamos a revisar los datos que seguro que te has equivocado:\n"+
                                    "--- #{name} ---\n"+
                                    "#{quantity}\n"+
                                    "Son correctos los datos @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
            response = pacasa_bot.await_message(message.from.username).text
            if(response == 'SI')
              pacasa_bot.send_message("Pues nada habra que guardarla, #{responses.borderias.sample}")
              notas.add_item(name, quantity)
              notas.add_value(name, message.from.username)

            else
              pacasa_bot.send_message("Como si supieras hacer algo, #{responses.borderias.sample}")
            end
          else
            pacasa_bot.send_message("A ver si aprendes a usar la basura esta:\n"+
                                    "/add (factura/compra/nota)")
        end

      ######################################################################################################################## /list
      when /\/list/
        message.text.slice!("/list ")
        action = message.text

        case action
          ############################################# factura
          when /facturas/
            text = "\xF0\x9F\x92\xB5 FACTURAS \xF0\x9F\x92\xB5 \n"
            for i in 0..(facturas.size-1)
              item = facturas.get_item(i)
              text += "_______________________\n"+
                      "\xE2\x96\xB6 #{item.first} \xE2\x97\x80\n"+
                      "\xF0\x9F\x92\xB0 Total: #{item.second.at(0)}€\n"+
                      "    \xF0\x9F\x92\xB2 Cada uno: #{item.second.at(0)/num_members}€\n"+
                      " \xF0\x9F\x91\x89 Ha pagado \n"
              if(item.second.size == 1)
                  text += "    \xF0\x9F\x91\x8C Nadie xdd\n"
              else
                for p in 1..(item.second.size-1)
                  text += "    \xE2\x9C\x85 @#{item.second.at(p)}\n"
                end
              end
              text += "_______________________\n\n"
            end
            pacasa_bot.send_message(text)
            
          ############################################# compra
          when /compras/
            text = "\xF0\x9F\x8F\xAC COMPRAS \xF0\x9F\x8F\xAC \n"
            for i in 0..(compras.size-1)
              item = compras.get_item(i)
              text += "_______________________\n"+
                      "\xE2\x96\xB6 @#{item.second.at(1)}: #{item.first} \xE2\x97\x80\n"+
                      "\xF0\x9F\x92\xB0 Total: #{item.second.at(0)}€\n"+
                      "    \xF0\x9F\x92\xB2 Cada uno: #{item.second.at(0)/num_members}€\n"+
                      " \xF0\x9F\x91\x89 Ha pagado \n"
              if(item.second.size == 2)
                  text += "    \xF0\x9F\x91\x8C Nadie xdd\n"
              else
                for p in 2..(item.second.size-1)
                  text += "    \xE2\x9C\x85 #{item.second.at(p)}\n"
                end
              end
              text += "_______________________\n\n"
            end
            pacasa_bot.send_message(text)

          ############################################# nota
          when /notas/
            text = "\xE2\x9C\x8F NOTAS \xE2\x9C\x8F \n"
            for i in 0..(notas.size-1)
              item = notas.get_item(i)
              text += "_______________________\n"+
                      "\xE2\x9D\x97 #{item.first} \xE2\x81\x89\n"+
                      "\xE2\xAD\x90 @#{item.second.at(1)}:\n"+
                      "#{item.second.at(0)}\n"+
                      "_______________________\n\n"
            end
            pacasa_bot.send_message(text)
          else
            pacasa_bot.send_message("A ver si aprendes a usar la basura esta:\n"+
                                    "/list (facturas/compras/notas)")
        end

      when /\/pagada/
        message.text.slice!("/pagada ")
        action = message.text

        case action
          ############################################# factura
          when /factura/
            if(message.from.username == admin)
              if(facturas.size>0)
                kb = Array.new
                for i in 0..(facturas.size-1)
                  kb << [String(facturas.get_item(i).first)]   
                end
                if(kb.size > 0)
                  pacasa_bot.send_message("Que factura te han pagado @#{message.from.username}?",pacasa_bot.create_keyboard(kb,true))

                  selected = pacasa_bot.await_message.text

                  mem = Array.new
                  if(num_members > 1)
                    for i in 1..(num_members-1)
                      mem << [String(members.get_item(i).first)] 
                    end
                    pacasa_bot.send_message("Quien te ha pagado @#{message.from.username}?",pacasa_bot.create_keyboard(mem,true))
                  end

                  payer = pacasa_bot.await_message.text

                  pacasa_bot.send_message("Entonces #{payer} te ha pagado #{selected}, es asi @#{admin}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
                    
                  response = pacasa_bot.await_message(message.from.username).text
                    
                  if(response == 'SI')
                    if(facturas.is_value(selected, payer))
                      pacasa_bot.send_message("Ese ya habia pagado inutil")                  
                    else
                      pacasa_bot.send_message("Impresionante, lo apunto")
                      facturas.add_value(selected, payer)
                    end
                  else
                    pacasa_bot.send_message("Ya me parecia a mi que era raro que alguien te hubiese pagado")
                  end
                else
                  pacasa_bot.send_message("No hay facturas pendiendes inutil")
                end
              else
                pacasa_bot.send_message("Vaya basura de administrador que no sabe que no hay ninguna factura")
              end

            else
              pacasa_bot.send_message("Pero donde vas tu, como si sirvieras para administrar algo")
            end
            
          ############################################# compra
          when /compra/
            if(compras.size > 0)
              kb = Array.new
              for i in 0..(compras.size-1)
                if(compras.get_item(i).second.at(1) == message.from.username)
                  kb << [String(compras.get_item(i).first)]  
                end 
              end
              if(kb.size>0)
                pacasa_bot.send_message("Que compra te han pagado @#{message.from.username}?",pacasa_bot.create_keyboard(kb,true))

                selected = pacasa_bot.await_message.text

                mem = Array.new
                if(num_members > 1)
                  for i in 0..(num_members-1)
                    if(members.get_item(i).first != message.from.username)
                      mem << [String(members.get_item(i).first)] 
                    end
                  end
                  pacasa_bot.send_message("Quien te ha pagado @#{message.from.username}?",pacasa_bot.create_keyboard(mem,true))
                end

                payer = pacasa_bot.await_message.text

                pacasa_bot.send_message("Entonces #{payer} te ha pagado #{selected}, es asi @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
                  
                response = pacasa_bot.await_message(message.from.username).text
                  
                if(response == 'SI')
                  if(compras.is_value(selected,payer))
                    pacasa_bot.send_message("Ese ya habia pagado inutil")                  
                  else
                    pacasa_bot.send_message("Impresionante, lo apunto")
                    compras.add_value(selected, payer)
                  end
                else
                  pacasa_bot.send_message("Ya me parecia a mi que era raro que alguien te hubiese pagado")
                end
              else
                pacasa_bot.send_message("Yo a veces tambien me invento que me tienen que pagar")
              end
            else
              pacasa_bot.send_message("No hay ninguna compra todavia makina")
            end


          else
            pacasa_bot.send_message("A ver si aprendes a usar la basura esta:\n"+
                                    "/pagada (factura/compra)\n"+
                                    "Solo puedes administrar pagos de facturas/pagos que hayas puesto tu")
          end

        when /\/remove/
          message.text.slice!("/pagada ")
        action = message.text

        case action
          ############################################# factura
          when /factura/
            if(message.from.username == admin)
              if(facturas.size>0)
                kb = Array.new
                for i in 0..(facturas.size-1)
                  kb << [String(facturas.get_item(i).first)]   
                end
                if(kb.size > 0)
                  pacasa_bot.send_message("Que factura quieres quitar @#{message.from.username}?",pacasa_bot.create_keyboard(kb,true))

                  selected = pacasa_bot.await_message.text

                  pacasa_bot.send_message("Entonces quieres quitar #{selected}, es asi @#{admin}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
                    
                  response = pacasa_bot.await_message(message.from.username).text
                    
                  if(response == 'SI')
                    pacasa_bot.send_message("Por fin, borrada correctamente")
                    facturas.remove_item(facturas.find(selected))
                  else
                    pacasa_bot.send_message("Me cago en la puta, ya podrias haberla borrado")
                  end
                else
                  pacasa_bot.send_message("No hay facturas pendiendes inutil")
                end
              else
                pacasa_bot.send_message("Vaya basura de administrador que no sabe que no hay ninguna factura")
              end

            else
              pacasa_bot.send_message("Pero donde vas tu, como si sirvieras para administrar algo")
            end
            
          ############################################# compra
          when /compra/
            if(compras.size > 0)
              kb = Array.new
              for i in 0..(compras.size-1)
                if(compras.get_item(i).second.at(1) == message.from.username)
                  kb << [String(compras.get_item(i).first)]  
                end 
              end
              if(kb.size>0)
                pacasa_bot.send_message("Que compra quieres quitar @#{message.from.username}?",pacasa_bot.create_keyboard(kb,true))

                selected = pacasa_bot.await_message.text

                pacasa_bot.send_message("Entonces pacasa que se va #{selected}, es asi @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
                  
                response = pacasa_bot.await_message(message.from.username).text
                  
                if(response == 'SI')
                  pacasa_bot.send_message("Nos vemos")
                  compras.remove_item(compras.find(selected))
                else
                  pacasa_bot.send_message("Ya te vale")
                end
              else
                pacasa_bot.send_message("Yo a veces tambien me invento que me tienen que pagar")
              end
            else
              pacasa_bot.send_message("No hay ninguna compra todavia makina")
            end

          when /nota/
            if(notas.size > 0)
              kb = Array.new
              for i in 0..(notas.size-1)
                if(notas.get_item(i).second.at(1) == message.from.username)
                  kb << [String(notas.get_item(i).first)]  
                end 
              end
              if(kb.size>0)
                pacasa_bot.send_message("Que nota quieres quitar @#{message.from.username}?",pacasa_bot.create_keyboard(kb,true))

                selected = pacasa_bot.await_message.text

                pacasa_bot.send_message("Entonces pacasa que se va #{selected}, es asi @#{message.from.username}?", pacasa_bot.create_keyboard([['SI'],['NO']],true))
                  
                response = pacasa_bot.await_message(message.from.username).text
                  
                if(response == 'SI')
                  pacasa_bot.send_message("Nos vemos")
                  notas.remove_item(notas.find(selected))
                else
                  pacasa_bot.send_message("Borra ya alguna de las peliculas que te montas")
                end
              else
                pacasa_bot.send_message("Pero que vas a tener tu escrito aqui si no sabes nu contar")
              end
            else
              pacasa_bot.send_message("Por suerte nadie ha decidido poner una nota todavia")
            end


          else
            pacasa_bot.send_message("A ver si aprendes a usar la basura esta:\n"+
                                    "/remove (factura/compra/nota)\n"+
                                    "Solo puedes quitar cosas que hayas puesto tu")
          end
        else
          pacasa_bot.send_message(responses.borderias.sample)
      end
  end

rescue SignalException => e   ################################################################################################################### FIN
  puts "\nSIGNAL => #{e} \nEl bot se ha parado, realizando tareas de mantenimiento...\n"

  puts "Hecho, tareas finalizadas, nos vemos\n"
end
  