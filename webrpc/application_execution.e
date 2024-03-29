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

	WSF_TIMEOUT_UTILITIES
		export
			{NONE} all
		end





create
	make

feature -- Basic operations




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
			l_github_service: LOGIN_WITH_GITHUB_SERVICE
			mesg: WSF_RESPONSE_MESSAGE
			mesgf: WSF_FILE_RESPONSE
 		do
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
			else
				if request.has_execution_variable ("user")  then
					-- Authenticated case
					if request.path_info.same_string_general ("/Logout.html") then
						handle_logout (request, response)
					elseif request.path_info.same_string_general ("/chat") then
						create {WSF_FILE_RESPONSE} mesg.make_with_content_type ({HTTP_MIME_TYPES}.text_html ,"chat.html")
						response.send (mesg)
					else
			 			s := "Hello World!"
						create dt.make_now_utc
						s.append (" (UTC time is " + dt.rfc850_string + ").")
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


feature -- Websocket execution

	new_websocket_handler (ws: WEB_SOCKET): WEB_SOCKET_HANDLER
		do
			create Result.make (ws, Current)
		end

	on_open (ws: WEB_SOCKET)
		local
		handle_client_connection_attempt : PEER_CLIENT_COMMUNICATION_HANDLER
		do
			set_timer_delay (1) -- Orginal was 1 second
--			ws.socket.set_timeout_ns(1000000000)
			execute_oauth_session_filter

			if ws.request.has_execution_variable ("user")  then

				if ws.request.request_uri.has_substring ("apptesttest") then
					create handle_client_connection_attempt.make
					handle_client_connection_attempt.add_client(ws.request)
				end
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
			handle_client_connection_attempt : PEER_CLIENT_COMMUNICATION_HANDLER
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
				create handle_client_connection_attempt.make
				handle_client_connection_attempt.handle_message(ws, ws.request, a_message)
			end
		end

	on_close (ws: WEB_SOCKET)
			-- Called after the WebSocket connection is closed.
		local
			handle_client_connection_attempt : PEER_CLIENT_COMMUNICATION_HANDLER
		do
			if ws.request.request_uri.has_substring ("apptesttest") then
				create handle_client_connection_attempt.make
				handle_client_connection_attempt.remove_client( ws.request)
			end
			ws.put_error ("Connection closed")
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
