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

make (new_client_id : separate STRING; new_client_token : separate STRING) --; new_client_socket : separate WEB_SOCKET)
do
	id := new_client_id
	token := new_client_token
--	socket := new_client_socket
end

feature -- Access

client_id : separate STRING
do
	Result := id
end

client_token : separate STRING
do
	Result := token
end

--client_socket : detachable separate WEB_SOCKET
--do
--	Result := socket
--end

feature -- comparsion

is_equal( other :   CLIENT ) : BOOLEAN
local
	temp, temp_other : STRING
do

	create temp_other.make_from_separate (other.client_id)
	create temp.make_from_separate (id)
	Result := temp.is_equal (temp_other) -- AND token.same_string (other.client_token)
end



feature {NONE} -- Internal

	id : separate STRING
	token : separate STRING
--	socket :  separate WEB_SOCKET


end
