note
	description: "Summary description for {CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CLIENT


inherit ANY
		redefine
			is_equal
			end


create
	make

feature -- make

make (new_client_id :  STRING; new_client_token : STRING)
do
	id := new_client_id
	token := new_client_token
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

is_equal( other :   CLIENT ) : BOOLEAN
do

	Result := id.is_equal (other.client_id) -- AND token.same_string (other.client_token)
end

add_message (json_string : STRING)
do
	messages.force (json_string)
end

get_message : STRING
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
