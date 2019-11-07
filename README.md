# peerjs_eiffel_server

It is a Eiffel version of https://github.com/peers/peerjs-server

Will not be a full implementation, e.g. not with the same felxibility to configure it. At least in a first version. 

A first version supports. 
- https only
- Only authentication with github. 
- One need to give an id from the client.

The server is built and tested with Eiffel version 19.05

Update ws.ini to your server configuration

Update github.ini according to the description in the file. In the Eiffel code the callback path is set to login_with_github_callback. If you chose somehting else then update the code and rebuild it.

Start the server and then navigate to https://your.server/chat 


