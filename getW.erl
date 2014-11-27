-module(getW).
-compile([export_all]).

start(WindowSize, L) ->
    Pid = spawn(?MODULE, worker, [WindowSize, L]),
    register(getW, Pid).

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
    io:format("st~n"),
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
