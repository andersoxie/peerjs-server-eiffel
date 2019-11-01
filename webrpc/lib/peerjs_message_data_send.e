note
	description: "Representation of a PEERJS Message Data"

class
	PEERJS_MESSAGE_DATA_SEND

inherit
	JSON_SERIALIZABLE
		redefine
			json_out
		end

create
	 make

feature {NONE} -- Initialization

	make (my_type, my_src, my_dst, my_payload: STRING)
			-- `make' with type, src, destination, and payload.
		do
			type := my_type
			src := my_src
			dst := my_dst
			payload := my_payload
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
		attribute
			create Result.make_empty
		end

feature -- Settings

	set_type(t: STRING)
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
		local
			l_json,
			l_front: STRING
			l_back: CHARACTER
		do
			l_json := Precursor
			check at_least_two: l_json.count >= 2 end
			l_front := l_json.substring (1, l_json.count - 1)
			l_back := l_json [l_json.count]
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

end
