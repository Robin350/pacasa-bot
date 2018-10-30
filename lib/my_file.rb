require 'fileutils'
#
# Coded by Robin Costas del Moral
#
# This class is only meant to use with my bots, therefore its functionality 
# is to manage them, so it is quite limited outside its purpose
#
# It takes a file and dump all its content into an array of lines
# so each line on the file represents one item
#  

class MyFile
  attr_accessor :content

  # file: a string with the path/name of the file
  def initialize(file)
    # filename: string with the name of the file
    # cfile: current file
    # content: array that will contain the separated lines of the file
    @filename = file
    @cfile = nil
    @content = Array.new

    # Is the file already created
    if(!File.exists?(file))
      # If it isnt, we create it
      puts "creating file #{file}\n"
      @cfile = File.new(file, "w+")
    else
      puts "file #{file} already exist\n"
      # If it is, Do we have read and write access?
      if(File.readable?(file) && File.writable?(file))
        # If so we open it
        @cfile = File.open(file, "a+") 
      else  
        abort("File #{file} cant be read or written");
      end
    end

    # If current file is still nil, something went wrong
    if(@cfile==nil)
      abort("An error ocurred while creating #{file}")
    end

    # We dump all the file content into an array of lines
    # content: an array of items we want to manage
    File.foreach(file) {|line| @content << line}

  end

  # Check if a given item is already in the array
  # item: the content we want to check
  # returns: true -> exist, false -> not exist
  def exists(item)
    return @content.include?(item)
  end

  # Checks if the current content is empty
  def empty
    return @content.empty?
  end

  # Add one item to the content array
  # item: the content we want to add
  # returns: 1 if already existed, 0 if successful, -1 unsuccessful
  def add_item(item)
    if(exists(item))
      return 1
    else
      @content << item
      return 0
    end
    return -1
  end

  # Remove one item from the content array
  # item: the content we want to remove
  # returns: 1 if didnt exist, 0 if successful, -1 unsuccessful
  def remove_item(item)
    if(exists(item))
      @content.delete(item)
      return 0
    else
      return 1
    end
    return -1
  end

  # Returns the item in index, if no index is specified, returns random
  # idex: the index of the item we want to get
  def get_item(index = nil)
    if(index == nil)
      return @content.sample
    else
      return @content[index]
    end
  end

  # Write all changes to content array to file
  # Overwrites whatever is in cfile 
  def write_to_file
    @cfile.rewind
    for line in @content
      @cfile.puts(line)
      @cfile.puts("\n")
    end

  end

  # Closes the file and saves the data written in it
  def close
    @cfile.close
  end

  # If you have closed the file it opens it again
  def open_again
    close_and_save
    initialize(@filename)
  end

  # closes and deletes the current file
  def delete
    FileUtils.rm(@filename)
  end

  # returns: A string with each line of the file preceded by ->
  def to_s
    string = ""
    if(@content.empty?)
      puts "The file is empty"
    else
      string = ""
      for line in @content
        string += "-> #{line} \n"
      end
    end

    return string
  end

end
