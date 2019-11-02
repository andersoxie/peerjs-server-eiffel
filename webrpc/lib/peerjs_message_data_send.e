note
	description: "Representation of a PEERJS Message Data"
	purpose: "[
		To receive a JSON data stream from an external client (`a_src') as `a_type' and then
		forward `a_payload' (i.e. client JSON data stream) to `a_dst' (destination).
		]"
	design_history: "[
		At initial creation of this class, the `payload' feature was being included in the serialization process
		inherited from {JSON_SERIALIZABLE}. A problem arose, where the well-formed client JSON was
		being placed as-is in `payload', and then that string was being further serialized, resulting
		in Escaped double-quotes, causing the forwarded JSON to be NOT well-formed. This was a bug.
		
		Two solutions presented themselves:
		
		A) Make `payload' inherit from JSON_SERIALIZABLE, such that it could be properly serialized
		into the JSON string being forwarded on.
		
		B) Leave `payload' as a {STRING}, but remove it from the serialization process, and hand-injecting
		it as the last key:value JSON pair in the JSON string to be forwarded. This meant the need to
		remove `payload' from the serialization process by NOT having it in the `convertible_features' list,
		nor in the `metadata_refreshed' list. To properly inject `payload' into the final JSON then requires
		a redefinition of `json_out', first fetching the serialization of Current, but then manually injecting
		(infixing) `payload' as a key:value pair at the end of the JSON stream.
		
		Solution #B was chosen because the system this class is a part of has no control over the JSON being
		sent by the client. It is the responsiblity of the client code to ensure that the `payload' JSON
		is well-formed. This class (and system) is on responsible to successfully forward the data to the
		destination. Therefore, the content of `payload' is ad-hoc and only needs simple injection. This
		means solution #B is the proper solution.
		]"

class
	PEERJS_MESSAGE_DATA_SEND

inherit
	JSON_SERIALIZABLE
		redefine
			json_out -- Refined for simple injection of `payload'.
		end

create
	 make

feature {NONE} -- Initialization

	make (a_type, a_src, a_dst, a_payload: STRING)
			-- `make' with type, src, destination, and payload.
		do
			type := a_type
			src := a_src
			dst := a_dst
			payload := a_payload
		end

feature -- Access

	type : STRING
			-- Type of message
		attribute
			create Result.make_empty
		end

	src: STRING
			-- Source
		attribute
			create Result.make_empty
		end

	dst: STRING
			-- destination
		attribute
			create Result.make_empty
		end

	payload: STRING
			-- JSON payload
			-- Well-formed JSON as provided by the Client of Current.
		attribute
			create Result.make_empty
		end

feature -- Settings

	set_type (t: STRING)
			-- `set_type' of `t' into `type'.
		do
			type := t
		end

	set_src (s: STRING)
			-- `set_src' of `s' into `src'.
		do
			src := s
		end

	set_dst (d: STRING)
			-- `set_dst' of `d' into `dst'.
		do
			dst := d
		end

	set_payload (p: like payload)
			-- `set_payload' of `p' into `payload'.
		do
			payload := p
		end

feature -- Output

	json_out: STRING
			--<Precursor>
			-- Inject `payload' as the last key:value pair.
		local
			l_json,
			l_front: STRING
			l_back: CHARACTER
		do
			l_json := Precursor
			check at_least_two: l_json.count >= 2 end
			l_front := l_json.substring (1, l_json.count - 1)
			l_back := l_json [l_json.count]
			check closing_brace: l_back = '}' end
			Result := l_front
			Result.append_string_general (",%"payload%":")
			Result.append_string_general (payload)
			Result.append_character (l_back)
		end

feature {NONE} -- Implementation

	convertible_features (a_object: ANY): ARRAY [STRING]
			-- <Precursor>
		once
			Result := <<"type", "src", "dst">>
		end

	metadata_refreshed( a_current: ANY): ARRAY [JSON_METADATA]
		--<Precursor>
	do
		Result := <<
					create {JSON_METADATA}.make_text_default,
					create {JSON_METADATA}.make_text_default,
					create {JSON_METADATA}.make_text_default
					>>
	end

note
	EIS: "name=specifications", "src="

end
