note
	description: "Connected client information"
	purpose: "[
			To keep information about a connected client
		]"
	design_history: "[
			Since it is not possible to connect directly when we recieve a message with a certain destination this class 
			keeps the recieved messages until this client connect with an heartbeat and gets the messages. The size of messages is set to 
			3 due to that during investigation of the javascript implementation of the server it was noticed that it often came about 3 messages when a client
			wanted to connect to another client.
			
			client_token is at the moemnt not used in this implementation
		]"

class
	CLIENT


inherit ANY
	redefine
		is_equal
	end


create
	make

feature -- make

	make (a_client_id :  STRING; a_client_token : STRING)
		do
			id := a_client_id
			token := a_client_token
			create messages.make(3)
			messages.automatic_grow
		end

feature -- Access

	client_id : STRING
		do
			Result := id
		end

	client_token : STRING
		do
			Result := token
		end

	feature -- comparsion

	is_equal( a_other :   CLIENT ) : BOOLEAN
		do
			Result := id.is_equal (a_other.client_id) -- AND token.same_string (other.client_token)
		end

	add_message (a_json_string : STRING)
		do
			messages.force (a_json_string)
		end

	consume_message : STRING
		-- when the server collects a message it is removed (consumed)
		do
			Result := ""
			if messages.count > 0 then
				messages.start
				Result := messages.item
				messages.remove
			end
		end



feature {NONE} -- Internal

	id :  STRING
	token : STRING
	messages : ARRAYED_LIST[STRING]

end
