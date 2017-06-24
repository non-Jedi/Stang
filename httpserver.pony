/*
Copyright 2017 Adam Beckmeyer

This file is part of Stang.

Stang is free software: you can redistribute it and/or modify it under the terms
of the GNU Affero General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Stang is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along
with Stang. If not, see <http://www.gnu.org/licenses/>.
*/

use "net/http"

actor Main
  """
  Http server responding according to matrix.org protocol.
  """
  new create(env: Env) =>
    let service = "50000"
    let limit: USize = 100
    let host = "localhost"

    let logger = CommonLog(env.out)

    let auth = try
      env.root as AmbientAuth
    else
      env.out.print("no auth to use network")
      return
    end

    // Start the top server control actor.
    HTTPServer(
      auth,
      ListenHandler(env),
      BackendMaker.create(env),
      logger
      where service=service, host=host, limit=limit, reversedns=auth)

class ListenHandler
  let _env: Env

  new iso create(env: Env) =>
    _env = env

  fun ref listening(server: HTTPServer ref) =>
    try
      (let host, let service) = server.local_address().name()
    else
      _env.out.print("Couldn't get local address.")
      server.dispose()
    end

  fun ref not_listening(server: HTTPServer ref) =>
    _env.out.print("Not listening.")

  fun ref closed(server: HTTPServer ref) =>
    _env.out.print("Shutdown Stang.")

class BackendMaker is HandlerFactory
  let _env: Env

  new val create(env: Env) =>
    _env = env

  fun apply(session: HTTPSession): HTTPHandler^ =>
    BackendHandler.create(_env, session)

class BackendHandler is HTTPHandler
  """
  Notification class for a single HTTP session.  A session can process
  several requests, one at a time.
  """

  let _env: Env val
  let _session: HTTPSession tag

  new ref create(env: Env, session: HTTPSession) =>
    """
    Create a handler for HTTP requests for a session.
    """
    _env = env
    _session = session

  fun ref apply(request: Payload val) =>
    """
    Process a request.
    """

    // Create lambda iso so that we can respond from other actors
    let respond = {(response: Payload iso) => _session(consume response)} iso
    Stang.create(consume respond)

actor Stang
  """
  This is where the matrix logic will begin. Probably here will be routing
  between the different api versions and then other actors will be spawned to do
  actual processing of the request.
  """

  new create(respond: {(Payload iso)} iso) =>
    let response: Payload iso = Payload.response()
    response.update("Content-type", "application/json")
    response.add_chunk("{1: 2}")
    respond(consume response)
