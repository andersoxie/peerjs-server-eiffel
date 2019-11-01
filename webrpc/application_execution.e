note
	description : "simple application execution"
	date        : "$Date: 2018-02-02 14:04:16 -0800 (Fri, 02 Feb 2018) $"
	revision    : "$Revision: 101350 $"

class
	APPLICATION_EXECUTION

inherit
	WSF_WEBSOCKET_EXECUTION
		redefine
			initialize
		end

	WEB_SOCKET_EVENT_I
		redefine
			on_timer
		end

	LOGIN_WITH_GITHUB_CONSTANTS

	WSF_URI_REWRITER
	rename
		uri as proxy_uri
	end

	WSF_TIMEOUT_UTILITIES
		export
			{NONE} all
		end





create
	make

feature -- Basic operations


	feature -- Helpers

		proxy_uri (a_request: WSF_REQUEST): STRING
				-- Request uri rewriten as url.
			do
--				Result := a_request.request_uri
				Result := ""
			end




		send_proxy_response (a_remote: READABLE_STRING_8; a_rewriter: detachable WSF_URI_REWRITER)
			local
				h: WSF_SIMPLE_REVERSE_PROXY_HANDLER
			do
				create h.make (a_remote)
				h.set_uri_rewriter (a_rewriter)
				h.set_uri_rewriter (create {WSF_AGENT_URI_REWRITER}.make (agent proxy_uri))
				h.set_timeout (30) -- 30 seconds
				h.set_connect_timeout (5_000) -- milliseconds = 5 seconds


				h.execute (request, response)
			end


	webrpc_connected_clients: separate CONNECTED_CLIENTS

		once ("PROCESS")
			create Result.make_with_capacity (10)
		end

	initialize
	local
		env : EXECUTION_ENVIRONMENT
		do
			Precursor
			create env
        end

	execute
		local
			s: STRING
			dt: HTTP_DATE
			shutdown_command :  WEBSOCKET_SERVER_SHUTDOWN_COMMAND
			l_github_service: LOGIN_WITH_GITHUB_SERVICE
			mesg: WSF_RESPONSE_MESSAGE
			mesgf: WSF_FILE_RESPONSE
 		do
 			create shutdown_command
 			shutdown_command.shutdown_server (Current)

			execute_oauth_session_filter

 			-- To send a response we need to setup, the status code and
 			-- the response headers.
			if request.path_info.same_string_general ("/favicon.ico") then
				response.put_header ({HTTP_STATUS_CODE}.not_found, <<["Content-Length", "0"]>>)
			elseif request.path_info.same_string_general ("/apptesttest") then
-- TODO Not sure how to respond to a PeerJS request.
 			s := "Hello World!"
			create dt.make_now_utc
			response.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-Type", "text/html"], ["Content-Length", s.count.out]>>)
			response.set_status_code ({HTTP_STATUS_CODE}.ok)
			response.header.put_content_type_text_html
			response.header.put_content_length (s.count)
			if request.is_keep_alive_http_connection then
				response.header.put_connection_keep_alive
			end

	response.put_string (s)

			elseif request.path_info.same_string_general ("/peer.min.js") then
				create {WSF_FILE_RESPONSE} mesg.make_with_content_type ({HTTP_MIME_TYPES}.text_javascript ,"peer.min.js")
				response.send (mesg)
			elseif request.path_info.same_string_general ("/send") then
				create {WSF_FILE_RESPONSE} mesgf.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"send.html")
				response.send (mesgf)
			elseif request.path_info.same_string_general ("/sendeiffelexternal") then
				create {WSF_FILE_RESPONSE} mesgf.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"sendeiffelexternal.html")
				response.send (mesgf)
			elseif request.path_info.same_string_general ("/sendeiffel") then
				create {WSF_FILE_RESPONSE} mesgf.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"sendeiffel.html")
--				response.put_header_line ("Access-Control-Allow-Origin: *") -- TODO Only for testing


				response.send (mesgf)
			elseif request.path_info.same_string_general ("/receive") then
				create {WSF_FILE_RESPONSE} mesg.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"receive.html")
				response.send (mesg)
			elseif request.path_info.same_string_general ("/receiveeiffel") then
				create {WSF_FILE_RESPONSE} mesg.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"receiveeiffel.html")
				response.send (mesg)
			elseif request.path_info.same_string_general ("/receiveeiffelexternal") then
				create {WSF_FILE_RESPONSE} mesg.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"receiveeiffelexternal.html")
				response.send (mesg)


			else

				if request.has_execution_variable ("user") and then attached {STRING_32}request.execution_variable ("user") as user and then (user.is_equal ("andersoxie") or user.is_equal ("LouiseBSharp")  or user.is_equal ("GabijaBSharp")) then
--				if request.has_execution_variable ("user")  then
					-- Authenticated case
					if request.path_info.same_string_general ("/Logout.html") then
						handle_logout (request, response)
					else

						if request.path_info.same_string_general ("/app") then
							s:=""
						--	s := websocket_app_html (request.server_name, request.server_port)
						else
				 			s := "Hello World!"
							if attached {STRING_32}request.execution_variable ("user") as user2 then
								s.append (user2)
							end
							create dt.make_now_utc
							s.append (" (UTC time is " + dt.rfc850_string + ").")
							s.append ("<p><h1><a href=%"/app%">BSharp AB ToDo</a></h1></p>")
						end
						response.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-Type", "text/html"], ["Content-Length", s.count.out]>>)
						response.set_status_code ({HTTP_STATUS_CODE}.ok)
						response.header.put_content_type_text_html
						response.header.put_content_length (s.count)
						if request.is_keep_alive_http_connection then
							response.header.put_connection_keep_alive
						end
						response.put_string (s)
					end
				else
					-- Not Authenticated case
                    l_github_service := github_service (request)

					-- URI /login_with_github
					if request.path_info.same_string_general ("/login_with_github") then
						handle_login_with_github (request, response)

					elseif
						-- URI /login_with_github_callback
						l_github_service /= Void and then
						request.path_info.same_string_general (l_github_service.callback_uri_path)
					then
						handle_login_with_github_callback (request, response)
					else
			 			s := "Hello World!"

						if attached request.execution_variable ("user") as user then
							s.append (user.tagged_out)
						end


						create dt.make_now_utc
						s.append (" (UTC time is " + dt.rfc850_string + ").")
						s.append ("<p><h1><a href=%"/login_with_github%">Login with GitHub</a></h1></p>")

						response.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-Type", "text/html"], ["Content-Length", s.count.out]>>)
						response.set_status_code ({HTTP_STATUS_CODE}.ok)
						response.header.put_content_type_text_html
						response.header.put_content_length (s.count)
						if request.is_keep_alive_http_connection then
							response.header.put_connection_keep_alive
						end
						response.put_string (s)

					end


				end
			end
		end

	execute_oauth_session_filter
                       -- Filter the request to set the current user if the oauth tokens exists.
 		do
			if
				attached {WSF_STRING} request.cookie (oauth_session_token) as l_roc_auth_session_token and then
				attached {WSF_STRING} request.cookie (oauth_user_login) as l_user
			then
				request.set_execution_variable ("user", l_user.value)
 			end
 		end

 	handle_login_with_github (req: WSF_REQUEST; res: WSF_RESPONSE)
 		local
 			l_github_service: LOGIN_WITH_GITHUB_SERVICE
 		do
			l_github_service := github_service (req)
			if l_github_service /= Void then
				l_github_service.set_error_procedure (agent handle_login_error)
				l_github_service.process_login (req, res)
 			else
 				handle_login_error (req, res, "Internal error! Set Github settings in %"github.ini%".")
 			end
 		end

	handle_login_with_github_callback (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			l_github_service: LOGIN_WITH_GITHUB_SERVICE
	 	do
	 		l_github_service := github_service (req)
	 		if l_github_service = void then
	 			handle_login_error (req, res, "Internal error (please set Github settings!)")
	 		else
	 			l_github_service.set_error_procedure (agent handle_login_error)
	 			l_github_service.process_oauth_callback (req, res,
	 				agent (i_req: WSF_REQUEST; i_res: WSF_RESPONSE; i_access_token: OAUTH_TOKEN; i_user: READABLE_STRING_GENERAL)
						local
	 						l_cookie: WSF_COOKIE
	 						conv: UTF_CONVERTER
	 						dt: DATE_TIME
	 						l_expires_in: INTEGER
	 					do
							if i_access_token.expires_in = 0 then
								l_expires_in := 3600
							else
								l_expires_in := i_access_token.expires_in
							end
							create dt.make_now_utc
							dt.second_add (l_expires_in)

							create l_cookie.make ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_session_token, i_access_token.token)
							l_cookie.set_max_age (l_expires_in)
							l_cookie.set_expiration_date (dt)
							l_cookie.set_path ("/")
							i_res.add_cookie (l_cookie)

							create l_cookie.make ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_user_login, conv.utf_32_string_to_utf_8_string_8 (i_user))
							l_cookie.set_max_age (l_expires_in)
							l_cookie.set_expiration_date (dt)
							l_cookie.set_path ("/")
							i_res.add_cookie (l_cookie)
							compute_response_redirect (i_req, i_res, i_req.absolute_script_url ("/app"))
	 					end
	 				)
	 		end
		end

		handle_logout (req: WSF_REQUEST; res: WSF_RESPONSE)
			local
				l_cookie: WSF_COOKIE
			do
				if
					attached {WSF_STRING} req.cookie ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_session_token) as l_cookie_token
				then
					req.unset_execution_variable ("user")
						-- Logout OAuth
					create l_cookie.make ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_session_token, "")
					l_cookie.set_path ("/")
					invalidate_cookie (l_cookie)
					res.add_cookie (l_cookie)

						-- Logout OAuth
					create l_cookie.make ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_user_login, "")
					l_cookie.set_path ("/")
					invalidate_cookie (l_cookie)
					res.add_cookie (l_cookie)

					req.unset_execution_variable ("user")
				end
				compute_response_redirect (req, res, req.absolute_script_url (""))
			end

	invalidate_cookie (a_cookie: WSF_COOKIE)
		do
			a_cookie.set_value ("") -- Remove data for security
			a_cookie.set_expiration_date (create {DATE_TIME}.make_from_epoch (0)) -- expiration in the past!
			a_cookie.set_max_age (0) -- Instructs the user-agent to delete the cookie
		end

 	compute_response_redirect (req: WSF_REQUEST; res: WSF_RESPONSE; a_url: STRING)
 		do
 			res.redirect_now (a_url)
 		end

	handle_login_error (req: WSF_REQUEST; res: WSF_RESPONSE; a_error_message: READABLE_STRING_GENERAL)
 		local
-- 			err: ERROR_PAGE
			msg: WSF_HTML_PAGE_RESPONSE
		do
--	   		create err.make (req.absolute_script_url (""), a_error_message, Void)
--	   		if attached err.representation as str then
--	   			compute_response_get (req, res, str)
--			else
	 			create msg.make
				msg.set_body (msg.html_encoded_string (a_error_message.to_string_32))
				res.send (msg)
--		   	end
		end


		github_service (req: WSF_REQUEST): detachable LOGIN_WITH_GITHUB_SERVICE
	 		local
	 			l_setup: LOGIN_WITH_GITHUB_SETUP
			do
				create l_setup.make_from_path (create {PATH}.make_from_string ("github.ini"))
				if l_setup.is_valid then
					create Result.make (l_setup, "/login_with_github_callback", req)
				end
			end

feature -- Implementation


	write_debug_message (ws: WEB_SOCKET;message : STRING)
	local
		env : EXECUTION_ENVIRONMENT
	do
		create env
		if attached env.item ("TEST_COMPUTER") as test then
				ws.send (Text_frame,message )
		end
	end


feature -- Websocket execution

	new_websocket_handler (ws: WEB_SOCKET): WEB_SOCKET_HANDLER
		do
			create Result.make (ws, Current)
		end

feature -- Websocket execution

	on_open (ws: WEB_SOCKET)
	local

		sep_client_id, sep_token_id:    separate STRING
		do
			set_timer_delay (1) -- Orginal was 1 second
--			ws.socket.set_timeout_ns(1000000000)

			if ws.request.request_uri.has_substring ("apptesttest") then
				if attached ws.request.string_item ("id") as  client_id and then not client_id.is_equal("null")then
					if attached ws.request.string_item ("token") as client_token then
						sep_client_id := client_id.out
						sep_token_id := client_token.out
						webrpc_connect_clients_put_client( webrpc_connected_clients, sep_client_id, sep_token_id)
					end
				end
			else

				if attached ws.request.cookie ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_user_login) as user2 then
					write_debug_message (ws, "You are: "  + user2.string_representation )
				end

				ws.put_error ("Connecting")
				write_debug_message (ws, "Hello, this is a simple demo with Websocket using Eiffel. (/help for more information).%N")

			end
		end

	on_binary (ws: WEB_SOCKET; a_message: READABLE_STRING_8)
		do

			if ws.request.request_uri.has_substring ("apptesttest") then
-- TODO Probably not necessary for Peerjs-servers
			else

				ws.send (Binary_frame, a_message)
			end
		end

	on_text (ws: WEB_SOCKET; a_message: READABLE_STRING_8)
		local
			i: INTEGER
			cmd_name: READABLE_STRING_8
			new_webRPC_data : PEERJS_MESSAGE_DATA
			send_data : PEERJS_MESSAGE_DATA_SEND
			JSON_string_to_send : STRING
			client_to_send_to : CLIENT
			json_string_to_heartbeat_client : separate STRING
			sep_client_id : separate STRING
			string_to_send : STRING
		do

			if ws.request.request_uri.has_substring ("apptesttest") then

				if attached ws.request.string_item ("id") as  client_id then


					create new_webRPC_data.make_from_json (a_message)
					io.error.put_string("INCOMING MESSAGE")
					io.error.new_line
					io.error.put_string (a_message)
					io.error.new_line
					if not new_webrpc_data.type.is_equal ("HEARTBEAT") then

						create send_data.make( new_webrpc_data.type, client_id, new_webrpc_data.get_dst, new_webrpc_data.get_payload)
						json_string_to_send := send_data.json_out

						io.error.put_string("INCOMING DATA")
						io.error.new_line
						io.error.put_string(json_string_to_send)
						io.error.new_line


						create client_to_send_to.make (new_webrpc_data.get_dst, "dummy_token")

						webrpc_connected_clients_send_command_to_client(webrpc_connected_clients, new_webrpc_data.get_dst, json_string_to_send)
					else
						-- HEARTBEAT
						sep_client_id := client_id.out
						json_string_to_heartbeat_client := webrpc_connected_clients_get_command_to_client(webrpc_connected_clients, sep_client_id)
						create string_to_send.make_from_separate (json_string_to_heartbeat_client)




						from until string_to_send.count = 0 loop

							io.error.put_string("SENDING DATA")
							io.error.new_line
							io.error.put_string(string_to_send)
							io.error.new_line

							ws.send_text ( string_to_send)
							json_string_to_heartbeat_client := webrpc_connected_clients_get_command_to_client(webrpc_connected_clients, sep_client_id)
							create string_to_send.make_from_separate (json_string_to_heartbeat_client)

						end
					end

				end


--				send (a_message)
			else
				if attached ws.request.cookie ({LOGIN_WITH_GITHUB_CONSTANTS}.oauth_user_login) as user2 then
					write_debug_message (ws, "You are: "  + user2.string_representation )
				end
			end
		end

	on_close (ws: WEB_SOCKET)
			-- Called after the WebSocket connection is closed.
		local
			client_to_be_removed : separate CLIENT
			sep_client_id : separate STRING
		do
			if ws.request.request_uri.has_substring ("apptesttest") then
				if attached ws.request.string_item ("id") as client_id then
					if attached ws.request.string_item ("token") as client_token then
						if not client_id.is_equal ("null") then
							sep_client_id := client_id.out
								webrpc_connected_clients_remove(webrpc_connected_clients, sep_client_id)
						end
					end
				end
			else
				ws.put_error ("Connection closed")
			end
		end



		webrpc_connected_clients_remove( connect_clinet_container : separate CONNECTED_CLIENTS; client : separate STRING )
		do
			connect_clinet_container.remove(client)
		end

		webrpc_connect_clients_put_client( connect_clinet_container : separate CONNECTED_CLIENTS; client, token : separate STRING  )
		do
			connect_clinet_container.put_client( client, token)
		end

		webrpc_connected_clients_send_command_to_client(connect_clinet_container : separate CONNECTED_CLIENTS; client_destination, json_string : separate STRING)
		do
			connect_clinet_container.send_command_to_client(client_destination, json_string)
		end

		webrpc_connected_clients_get_command_to_client (connect_clinet_container : separate CONNECTED_CLIENTS; client_destination : separate STRING) : separate STRING
		do
			Result := connect_clinet_container.get_command_to_client(client_destination)
		end


	on_timer (ws: WEB_SOCKET)
			-- <Precursor>.
			-- If ever the file ".stop" exists, stop gracefully the connection.
		local
			fut: FILE_UTILITIES
		do
			if fut.file_exists (".stop") then
				ws.send_text ("End of the communication ...%N")
				ws.send_connection_close ("")
			end
		end



end
