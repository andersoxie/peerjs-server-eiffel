note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	PEERJS_SERVER_TEST_SET

inherit
	EQA_TEST_SET

feature -- Test routines

	test_peerjs_message_data
			-- New test routine
		note
			testing:  "covers/{PEERJS_MESSAGE_DATA}.make_from_json"
		local

			message : PEERJS_MESSAGE_DATA
		do
			create message.make_from_json ("{%"type%":%"OFFER%",%"payload%":{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 1222797698173017708 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:GtP7\r\na=ice-pwd:f9KzGLVHPP+zd/6hgDZGZo3q\r\na=ice-options:trickle\r\na=fingerprint:sha-256 53:C5:6C:A0:2C:86:B9:10:82:EB:A4:46:A5:EF:FE:48:97:08:6C:30:95:57:27:65:64:25:5C:C1:9D:BC:C1:3F\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_9p06ljfrtcn%",%"browser%":%"Chrome%",%"label%":%"dc_9p06ljfrtcn%",%"reliable%":true,%"serialization%":%"binary%"},%"dst%":%"EiffelTest%"}")
			assert ("Payload is correct", message.get_payload.is_equal ("{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 1222797698173017708 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:GtP7\r\na=ice-pwd:f9KzGLVHPP+zd/6hgDZGZo3q\r\na=ice-options:trickle\r\na=fingerprint:sha-256 53:C5:6C:A0:2C:86:B9:10:82:EB:A4:46:A5:EF:FE:48:97:08:6C:30:95:57:27:65:64:25:5C:C1:9D:BC:C1:3F\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_9p06ljfrtcn%",%"browser%":%"Chrome%",%"label%":%"dc_9p06ljfrtcn%",%"reliable%":true,%"serialization%":%"binary%"}"))
			assert ("Destination is correct", message.get_dst.is_equal ("EiffelTest"))
			assert ("Source is emnpty", message.get_src.is_equal (""))
		end

		test_peerjs_message_data_payload
				-- New test routine
			note
				testing:  "covers/{PEERJS_MESSAGE_DATA_SEND}.payload"
			local
				data : PEERJS_MESSAGE_DATA_SEND
				json_string : STRING
				correct_json_string : STRING
			do

				create data.make( "TEST", "Test_id", "Test_dst", "{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 5464478143710614650 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:L1Oh\r\na=ice-pwd:MuNDBlxgHnQrMJG2bGTlfqGs\r\na=ice-options:trickle\r\na=fingerprint:sha-256 71:D1:31:49:90:3B:E8:78:BF:D8:33:A5:A4:56:42:EC:F0:4D:7F:04:F8:D1:9E:A0:B9:87:87:6C:84:24:58:AD\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_nqofifzjapq%",%"browser%":%"Chrome%",%"label%":%"dc_nqofifzjapq%",%"reliable%":true,%"serialization%":%"binary%"}")
				json_string := data.json_out
				correct_json_string := "{%"type%":%"TEST%",%"src%":%"Test_id%",%"dst%":%"Test_dst%",%"payload%":{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 5464478143710614650 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:L1Oh\r\na=ice-pwd:MuNDBlxgHnQrMJG2bGTlfqGs\r\na=ice-options:trickle\r\na=fingerprint:sha-256 71:D1:31:49:90:3B:E8:78:BF:D8:33:A5:A4:56:42:EC:F0:4D:7F:04:F8:D1:9E:A0:B9:87:87:6C:84:24:58:AD\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_nqofifzjapq%",%"browser%":%"Chrome%",%"label%":%"dc_nqofifzjapq%",%"reliable%":true,%"serialization%":%"binary%"}}"

				assert ("Payload not modified", json_string.is_equal (correct_json_string))
			end



		test_peerjs_message_data_payload_with_adjustments
				-- New test routine
			note
				testing:  "covers/{PEERJS_MESSAGE_DATA_SEND}.payload"
			local
				data : PEERJS_MESSAGE_DATA_SEND
				json_string : STRING
				correct_json_string : STRING
			do

				create data.make( "TEST", "Test_id", "Test_dst", "{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 5464478143710614650 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:L1Oh\r\na=ice-pwd:MuNDBlxgHnQrMJG2bGTlfqGs\r\na=ice-options:trickle\r\na=fingerprint:sha-256 71:D1:31:49:90:3B:E8:78:BF:D8:33:A5:A4:56:42:EC:F0:4D:7F:04:F8:D1:9E:A0:B9:87:87:6C:84:24:58:AD\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_nqofifzjapq%",%"browser%":%"Chrome%",%"label%":%"dc_nqofifzjapq%",%"reliable%":true,%"serialization%":%"binary%"}")
				json_string := data.json_out

				json_string.replace_substring_all ("\%"", "%"")
				json_string.replace_substring_all ("\\", "\")
				json_string.replace_substring_all ("%"payload%":%"", "%"payload%":")
				json_string.replace_substring_all ("%"}%"}", "%"}}")

				correct_json_string := "{%"type%":%"TEST%",%"src%":%"Test_id%",%"dst%":%"Test_dst%",%"payload%":{%"sdp%":{%"type%":%"offer%",%"sdp%":%"v=0\r\no=- 5464478143710614650 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE 0\r\na=msid-semantic: WMS\r\nm=application 9 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:L1Oh\r\na=ice-pwd:MuNDBlxgHnQrMJG2bGTlfqGs\r\na=ice-options:trickle\r\na=fingerprint:sha-256 71:D1:31:49:90:3B:E8:78:BF:D8:33:A5:A4:56:42:EC:F0:4D:7F:04:F8:D1:9E:A0:B9:87:87:6C:84:24:58:AD\r\na=setup:actpass\r\na=mid:0\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n%"},%"type%":%"data%",%"connectionId%":%"dc_nqofifzjapq%",%"browser%":%"Chrome%",%"label%":%"dc_nqofifzjapq%",%"reliable%":true,%"serialization%":%"binary%"}}"

				assert ("Payload not modified", json_string.is_equal (correct_json_string))
			end

		test_peerjs_message_data__simple_payload
				-- New test routine
			note
				testing:  "covers/{PEERJS_MESSAGE_DATA_SEND}.payload"
			local
				data : PEERJS_MESSAGE_DATA_SEND
				json_string : STRING
				correct_json_string : STRING
			do

				create data.make( "TEST", "Test_id", "Test_dst", "{%"serialization%":%"binary%"}")
				json_string := data.json_out


				correct_json_string := "{%"type%":%"TEST%",%"src%":%"Test_id%",%"dst%":%"Test_dst%",%"payload%":{%"serialization%":%"binary%"}}"

				assert ("Payload not modified", json_string.is_equal (correct_json_string))
			end

		test_peerjs_message_data__simple_payload_with_adjustments
				-- New test routine
			note
				testing:  "covers/{PEERJS_MESSAGE_DATA_SEND}.payload"
			local
				data : PEERJS_MESSAGE_DATA_SEND
				json_string : STRING
				correct_json_string : STRING
			do

				create data.make( "TEST", "Test_id", "Test_dst", "{%"serialization%":%"binary%"}")
				json_string := data.json_out

				json_string.replace_substring_all ("\%"", "%"")
				json_string.replace_substring_all ("\\", "\")
				json_string.replace_substring_all ("%"payload%":%"", "%"payload%":")
				json_string.replace_substring_all ("%"}%"}", "%"}}")

				correct_json_string := "{%"type%":%"TEST%",%"src%":%"Test_id%",%"dst%":%"Test_dst%",%"payload%":{%"serialization%":%"binary%"}}"

				assert ("Payload not modified", json_string.is_equal (correct_json_string))
			end




end


