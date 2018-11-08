#
# Coded by Robin Costas del Moral & Antonio Jaimez Jimenez
#
# This class is only meant to use with our bots, therefore its functionality 
# is to manage them, so it is quite limited outside its purpose
#  

require_relative 'my_responses'

class MyBot

  attr_accessor :current_chat

  def initialize(token)
    @bot = Telegrammer::Bot.new(token)
    @current_chat = nil
    @responses = MyResponses.instance
  end

  def send_message(text, reply_markup=nil)
    if(reply_markup.nil?)
      @bot.send_message(chat_id: @current_chat, text: text, reply_markup: reply_markup)
    else
      @bot.send_message(chat_id: @current_chat, text: text)
    end
  end

  def await_message(user = nil)
    @bot.get_updates do |update|
      if update.is_a?(Telegrammer::DataTypes::Message)
        if(user.nil?)
          return update
        elsif(user == update.from.username)
          return update
        end
      end
    end
  end  

  def create_keyboard(options)
    answers = Telegrammer::DataTypes::ReplyKeyboardMarkup
    .new(keyboard: options, one_time_keyboard: true)

    return answers
  end

  def get_force_reply
    return Telegrammer::DataTypes::ForceReply.new(force_reply: true, selective: true)
  end
  

end