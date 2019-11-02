note
	description: "Recieved data from client"
	purpose: "[
		To convert well formed JSON form a client to its, for the server, important components.
		Type gives us knowledge of the command sent to this server. It id diveded of two categorise

		1. Heartbeat, indicating that the client is still alive
		2. Connection request and answers when a webrpc connectio is intialized between two clients.

		The later should be forwarded to the dst.This is done by creating an object of type PEERJS_MESSAGE_DATA_SEND
		that reorders the original json_string to the order that the reciever expects.
		]"
	design_history: "[
		It would be possible to break down payload to its components but this way the solution is more general
		and can handle of the payload format and/or contentis changed in the peerjs solution
		]"

class
	PEERJS_MESSAGE_DATA

inherit
	JSON_DESERIALIZABLE

create
	 make_from_json

feature

	type : STRING
	dst: detachable STRING
	src: detachable STRING
	payload: detachable STRING

	convertible_features (a_object: ANY): ARRAY [STRING]
			-- <Precursor>
		once
			Result := <<"type", "payload","dst", "src">>
		end

	make_from_json (a_json: STRING)
		require else											-- This must be here because the ancestor is False.
			True												    --	Leaving it False, will cause this to fail.
		local
			l_object: detachable JSON_OBJECT					        -- You must have one of these because ...
			l_any: detachable ANY
		do
			l_object := json_string_to_json_object (a_json)		-- ... the `a_json' STRING is parsed to a JSON_OBJECT.
			check attached_object: attached l_object end		  -- This proves that our JSON parsing was okay.

			type := json_object_to_json_string_representation_attached ("type", l_object)
			dst := json_object_to_json_string_representation ("dst", l_object)
			src := json_object_to_json_string_representation ("src", l_object)
			payload := json_object_to_json_string_representation ("payload", l_object)
		end

	get_dst : STRING
		do
			if attached dst as res then
				Result := res
			else
				Result := ""
			end
		end

	get_src : STRING
		do
			if attached src as res then
				Result := res
			else
				Result := ""
			end
		end


	get_payload : STRING
		do
			if attached payload as res then
				Result := res
			else
				Result := ""
			end
		end

	metadata_refreshed( a_current: ANY): ARRAY [JSON_METADATA]
		do
			Result := <<>>
		end

end
