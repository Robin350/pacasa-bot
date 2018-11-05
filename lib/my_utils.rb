#
# Coded by Robin Costas del Moral
#
# This class is only meant to use with my bots, therefore its functionality 
# is to manage them, so it is quite limited outside its purpose
#
# This class only manages a pair of data, you can read and write on it
# and thats all. Extra methods for calling them however you want
#  

class MyUtils
  def self.await_response(user, pacasa_bot)
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
  
  def self.await_int(user, pacasa_bot)
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
  
  def self.await_float(user, pacasa_bot)
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
  

end