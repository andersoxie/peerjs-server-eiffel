note
	description: "Summary description for {PEER_CLIENT_COMMINCATION_HANDLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PEER_CLIENT_COMMUNICATION_HANDLER

inherit
LOGGABLE


create
	make


feature

	make
		do

		end

	add_client( a_request : WSF_REQUEST)
		local
			sep_client_id, sep_token_id: separate STRING
		do
			if attached a_request.string_item ("id") as  client_id and then not client_id.is_equal("null")then
				if attached a_request.string_item ("token") as client_token then
					sep_client_id := client_id.out
					sep_token_id := client_token.out
					webrpc_connect_clients_put_client( webrpc_connected_clients, sep_client_id, sep_token_id)
				end
			end
		end

	handle_message(ws: WEB_SOCKET; a_request : WSF_REQUEST; a_message: READABLE_STRING_8)
		local
			new_webRPC_data : PEERJS_MESSAGE_DATA
			send_data : PEERJS_MESSAGE_DATA_SEND
			JSON_string_to_send : STRING
			client_to_send_to : CLIENT
			json_string_to_heartbeat_client : separate STRING
			sep_client_id : separate STRING
			string_to_send : STRING

		do
			if attached a_request.string_item ("id") as  client_id then
				create new_webRPC_data.make_from_json (a_message)
				if not new_webrpc_data.type.is_equal ("HEARTBEAT") then
					logger.write_debug ("Peer_client_commuinication, handle_message store message to client when getting a heartbeat: client_id(sending the message):" + client_id + " | message: " + a_message)
					create send_data.make( new_webrpc_data.type, client_id, new_webrpc_data.get_dst, new_webrpc_data.get_payload)
					json_string_to_send := send_data.json_out
					create client_to_send_to.make (new_webrpc_data.get_dst, "dummy_token")
					webrpc_connected_clients_send_command_to_client(webrpc_connected_clients, new_webrpc_data.get_dst, json_string_to_send)
				else
					-- HEARTBEAT
					sep_client_id := client_id.out
					json_string_to_heartbeat_client := webrpc_connected_clients_get_command_to_client(webrpc_connected_clients, sep_client_id)
					create string_to_send.make_from_separate (json_string_to_heartbeat_client)

					from until string_to_send.count = 0 loop
						logger.write_debug ("Peer_client_commuinication, handle_message send message to client when getting a heartbeat: client_id(recieving the message):" + client_id + " | message: " + string_to_send)
						ws.send_text ( string_to_send)
						json_string_to_heartbeat_client := webrpc_connected_clients_get_command_to_client(webrpc_connected_clients, sep_client_id)
						create string_to_send.make_from_separate (json_string_to_heartbeat_client)
					end
				end
			end
		end



	remove_client( a_request : WSF_REQUEST)
		local
			sep_client_id : separate STRING
		do
			if attached a_request.string_item ("id") as client_id then
				if attached a_request.string_item ("token") as client_token then
					if not client_id.is_equal ("null") then
						sep_client_id := client_id.out
							webrpc_connected_clients_remove(webrpc_connected_clients, sep_client_id)
					end
				end
			end

		end

feature {NONE}

		webrpc_connected_clients_remove( connect_client_container : separate CONNECTED_CLIENTS; client : separate STRING )
		do
			connect_client_container.remove(client)
		end

		webrpc_connect_clients_put_client( connect_client_container : separate CONNECTED_CLIENTS; client, token : separate STRING  )
		do
			connect_client_container.put_client( client, token)
		end

		webrpc_connected_clients_send_command_to_client(connect_client_container : separate CONNECTED_CLIENTS; client_destination, json_string : separate STRING)
		do
			connect_client_container.post_command_to_client(client_destination, json_string)
		end

		webrpc_connected_clients_get_command_to_client (connect_client_container : separate CONNECTED_CLIENTS; client_destination : separate STRING) : separate STRING
		do
			Result := connect_client_container.consume_client_command(client_destination)
		end


	webrpc_connected_clients: separate CONNECTED_CLIENTS

		once ("PROCESS")
			create Result.make_with_capacity (10)
		end


end
