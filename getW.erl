-module(getW).
-compile([export_all]).

start(WindowSize, L) when WindowSize =< length(L) ->
    Pid = spawn(?MODULE, worker, [WindowSize, L]),
    register(getW, Pid);
start(_, _) ->
    erlang:throw(list_too_short).

set(L) ->
    getW ! {set, L}.

get() ->
    getW ! {get, self()},
    receive
        {ok,L3} ->
            L3
    end.

stop() ->
    getW ! {stop}.

worker(WindowSize, L) ->
    receive
        {set, L1} ->
            worker(WindowSize, L1);
        {get, Caller} ->
            try
                lists:split(WindowSize, L)
            of
                {Window, _Rest} ->
                    Caller ! {ok, Window},
                    [_H|L1] = L,
                    worker(WindowSize, L1)
            catch
                _Exception:_Reason ->
                    Caller ! {ok, []},
                    worker(WindowSize, [])
            end;
        {stop} ->
            ok
    end.

consumer(WindowSize, Iterations) ->
    L = getW:get(),
    if 
        length(L) =:= WindowSize ->
           consumer(WindowSize, Iterations + 1);
        true ->
           io:format("~p iterations~n", [Iterations])
    end.

test() ->
    getW:start(4,lists:seq(1,10000)),
    consumer(4,0),
    getW:stop().
