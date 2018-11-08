# Coded by Toni el Gordo

require 'mongo'

class DbOperations
    def db_connect()
        
        client = Mongo::Client.new(['127.0.0.1:27017'],:database => 'pacasabot')

        return client
    end

    ################################ FLATS MANAGEMENT ###################################
    #
    # A flat will be a doc like this: {_num : "1", members : ["Pepito","Jeremiah"]}
    #                                       
    ######################################################################################
    def get_flats()

        db = db_connect()

        collection = db[:flats]

        return collection

    end

    def insert_new_flat(doc)
        
        db = db_connect()

        flats = db[:flats]

        result = flats.insert_one(doc)

        puts result.n
    end

    def remove_flat(num)
        db = db_connect()
        flats = db[:flats]
        result = flats.delete_one( {  _num : num } )
        puts result.n
    end
    ####################################################################################

    ################################ USERS MANAGEMENT ##################################
    #
    # A user will be a doc like this: {_id : "1", alias : "@Jeremiah"}
    #
    ####################################################################################
    def get_users(flat_id)
        
        db = db_connect()
        
        flats = db[:flats]

        flat = flats.find( { _id : flat_id } ).first

        users = flat['members']

        return users
    end

    def create_user(doc)
        db = db_conect()

        user_collection = db[:users]

        result = user_collection.insert_one(doc)

        puts result.n
    end

    def add_user_to_flat(user_id, flat_id)
        db = db_connect()
        flats_collection = db[:flats]

        flat = flats_collection.find_one({_num : flat_id})
        
        if flat
            members = flat["members"]
            members << user_id
            result= flats_collection.update_one( {_num : flat_id},
                                                 {'$set' => {'members' => members}} 
                                               )
            if result != 1
                puts "Error: Failed at updating flat members"
        else
            puts "Error: no such id for a flat"
        end
        user_collection = db[:users]
    end
    
    #######################################################################################
    #
    # A note will be a doc like this: { "Title" : "Example Title" ,flat_id: "1", author : "Jeremiah", content : "Example content"}
    #
    #######################################################################################

    #######################################################################################
    #                   AUX FUNCS
    #######################################################################################

    def get_user_flat(user)
        flats_collection = db[:flats]
        flat_num = nil

        flats_collection.each do |flat|
            members = flat["members"]
            if user in members
                flat_num = flat["id"]
        
        if !flat_num
            puts "Error: author is not in a flat"    
            return nil
        else
            return flat_id
    end
    
    def create_note(user_author,note_content)
        
        db = db_connect()
        
        flat_num = get_user_flat(user_author)

        notes_collection = db[:notes]
        
        doc = { flat_id : flat_num,
                author : user_autor,
                content : note_content }

        result = notes_collection.insert_one(doc)

        puts result
        
    end

    def get_note(user_author,title)
        db = db_connect()

        notes_collection = db[:notes]
        note = nil
        user_notes = notes_collection.find( { author : user_author })
        user_notes.each do |i|
            if i["title"] == title
                note = i
        if note
            return note
        else 
            return nil
        end

    end

    def edit_note(user_author,new_content,title_note)
        db = db_connect()

        flat_num = get_user_flat(user_author)

        notes_collection = db[:notes]

        if note
            notes_collection.update_one( { title : tittle_note,
                                         {'$set' => {'content' => new_content}} 
          )

        else
            puts "Error: There isnt a note with such title"
        end
        

    end
end