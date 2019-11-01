note
	description: "Summary description for {PEERJS_MESSAGE_DATA}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

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



		io.error.put_string("JSONSTRING")
		io.error.new_line
		io.error.put_string(a_json)
		io.error.new_line


		io.error.put_string("PAYLOAD")
		io.error.new_line
		if attached payload as p then
			io.error.put_string(p)
		else
			io.error.put_string("No PAYLOAD!!!")
		end
		io.error.new_line

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
		Result := <<
					>>
	end




-- Different examples of strings from a Peerjs client
-- {"type":"OFFER","payload":{"sdp":{"type":"offer","sdp":"v=0\r\no=- 1222797698173017708 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:GtP7\r\na=ice-pwd:f9KzGLVHPP+zd/6hgDZGZo3q\r\na=ice-options:trickle\r\na=fingerprint:sha-256 53:C5:6C:A0:2C:86:B9:10:82:EB:A4:46:A5:EF:FE:48:97:08:6C:30:95:57:27:65:64:25:5C:C1:9D:BC:C1:3F\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n"},"type":"data","connectionId":"dc_9p06ljfrtcn","browser":"Chrome","label":"dc_9p06ljfrtcn","reliable":true,"serialization":"binary"},"dst":"EiffelTest"}

end
