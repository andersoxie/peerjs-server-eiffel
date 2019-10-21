note
	description : "simple application root class"
	date        : "$Date: 2016-10-19 04:13:16 -0700 (Wed, 19 Oct 2016) $"
	revision    : "$Revision: 99307 $"

class
	APPLICATION_TODO

create
	make_and_launch

feature {NONE} -- Initialization

	make_and_launch
		local
			l_launcher: WSF_STANDALONE_WEBSOCKET_SERVICE_LAUNCHER [APPLICATION_EXECUTION]
			opts: WSF_STANDALONE_WEBSOCKET_SERVICE_OPTIONS

		do
			create opts
			if opts.is_secure_connection_supported then
				opts.is_secure := True
				opts.set_secure_protocol_to_tls_1_2
				opts.secure_certificate := "ca.crt"
				opts.secure_certificate_key := "ca.key"
			end

			opts.import_ini_file_options ("ws.ini")
			create l_launcher.make_and_launch (opts)
		end

end
