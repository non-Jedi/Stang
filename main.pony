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
  Starts http server responding according to matrix.org protocol.
  """
  new create(env: Env) =>
    let service: String val = "8008"
    let limit: USize = 100
    let host = "localhost"

    let logger = CommonLog(env.out)

    let auth = try
      env.root as AmbientAuth
    else
      env.out.print("no auth to use network")
      return
    end

    // Create any needed shared actors
    let apis: ApiCollection val = ApiCollection.create()

    // Start the top server control actor.
    HTTPServer(
      auth,
      ListenHandler(env.out),
      BackendMaker.create(env, apis),
      logger
      where service=service, host=host, limit=limit, reversedns=auth)

class ListenHandler
  let _out: StdStream tag

  new iso create(out: StdStream tag) =>
    _out = out

  fun ref listening(server: HTTPServer ref) =>
    try
      (let host, let service) = server.local_address().name()
    else
      _out.print("Couldn't get local address.")
      server.dispose()
    end

  fun ref not_listening(server: HTTPServer ref) =>
    _out.print("Not listening.")

  fun ref closed(server: HTTPServer ref) =>
    _out.print("Shutdown Stang.")

class BackendMaker is HandlerFactory
  let _env: Env
  let _apis: ApiCollection val

  new val create(env: Env, apis: ApiCollection val) =>
    _env = env
    _apis = apis

  fun apply(session: HTTPSession): HTTPHandler^ =>
    BackendHandler.create(_env, _apis, session)

class BackendHandler is HTTPHandler
  """
  Notification class for a single HTTP session.  A session can process
  several requests, one at a time. This class routs the request to the actor
  that can handle it.
  """

  let _env: Env val
  let _session: HTTPSession tag
  let _apis: ApiCollection val

  new create(env: Env, apis: ApiCollection, session: HTTPSession) =>
    """
    Create a handler for HTTP requests for a session.
    """
    _env = env
    _apis = apis
    _session = session

  fun apply(request': Payload val) =>
    """
    Process a request. (Check for "_matrix" in path and send on)
    """
    let url = StangURL.create(request'.url)
    let respond = {(response: Payload iso) => _session(consume response)} iso
    let responder = Responder(request', consume respond)

    match (url(1), url(2))
      | ("_matrix", "client") => route(responder)
    else
      let response = Payload.response(StatusNotFound)
      responder.respond(consume response)
    end

  fun route(responder: Responder val) =>
    """
    Sends the request on to an actor based on url.
    """
    let url = StangURL.create(responder.request.url)
    match url(3)
      | "r0" => _apis.r0(responder)
      | "versions" => _apis.versions(responder)
    else
      let response = Payload.response(StatusNotFound)
      responder.respond(consume response)
    end
