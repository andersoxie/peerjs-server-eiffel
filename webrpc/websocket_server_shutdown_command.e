note
	description: "Summary description for {WEBSOCKET_SERVER_SHUTDOWN_COMMAND}. Posted in Eiffel Web Framework Googel Group"
	author: "Jocelyn Fiat"
	date: "$Date$"
	revision: "$Revision$"

class
    WEBSOCKET_SERVER_SHUTDOWN_COMMAND

    inherit
    	EXECUTION_ENVIRONMENT

feature -- Operation

    shutdown_server ( exec: WSF_EXECUTION)
        do
            if attached exec.request.wgi_connector as conn then
                shutdown_connector (conn)
            end
        end

    shutdown_connector (conn: attached like {WSF_EXECUTION}.wgi_request.wgi_connector)
   		local
			fut: FILE_UTILITIES
			f: RAW_FILE
			shutdown: BOOLEAN
        do

			if fut.file_exists (".shutdown") then
				create f.make_with_name (".shutdown")
				f.delete
	            if attached {separate WGI_STANDALONE_WEBSOCKET_CONNECTOR [WSF_EXECUTION]} conn as st_conn then
	                st_conn.shutdown_server
	            end
	            shutdown := true
            end
        end
end
