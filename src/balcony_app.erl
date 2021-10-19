%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(balcony_app).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _Args) ->
    io:format("Starting:~p~n",[file:get_cwd()]),
    Port=8081,
    ssl:start(),
    application:start(crypto),
    application:start(ranch), 
    application:start(cowlib), 
    application:start(cowboy),    
    Dir=applications/balcony,
    HtmlFile="index.html",

    HelloRoute = { "/", cowboy_static, {priv_file,Dir, HtmlFile} },
    WebSocketRoute = {"/please_upgrade_to_websocket", balcony_handler, []},
    CatchallRoute = {"/[...]", no_matching_route_handler, []},

    Dispatch = cowboy_router:compile([
				      {'_',
				       [HelloRoute, 
					WebSocketRoute, 
					CatchallRoute
				       ]
				      }
				     ]),
    {ok, _} = cowboy:start_clear(http, [{port, Port}], #{
							 env => #{dispatch => Dispatch}
							}),
    {ok,Pid}= balcony_sup:start_link(),
    {ok,Pid}.
   
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
    ok = cowboy:stop_listener(http).


%% ====================================================================
%% Internal functions
%% ====================================================================

