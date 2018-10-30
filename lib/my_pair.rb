#
# Coded by Robin Costas del Moral
#
# This class is only meant to use with my bots, therefore its functionality 
# is to manage them, so it is quite limited outside its purpose
#
# This class only manages a pair of data, you can read and write on it
# and thats all. Extra methods for calling them however you want
#  

class MyPair
  attr_accessor :first, :second

  def initialize(first = nil, second = nil)
    @first = first
    @second = second
  end

  def x(value = nil)
    if(value == nil)
      return @first      
    else
      @first = value
    end
  end

  def y(value = nil)
    if(value == nil)
      return @second      
    else
      @second = value
    end
  end

end