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

class Stang
  """
  This is where the matrix logic will begin. Probably here will be routing
  between the different api versions and then other actors will be spawned to do
  actual processing of the request.
  """

  new create(request: Payload val, respond: {(Payload iso)} iso) =>
    let url = StangURL.create(request.url)
    // We already know that url(1) is "_matrix"
    match url(2)
      | "client" => ClientServerApi.create(request, consume respond)
    else
      let response = Payload.response(StatusNotFound)
      respond(consume response)
    end

actor ClientServerApi
  let _respond: {(Payload iso)} iso
  let _request: Payload val

  new create(request: Payload val, respond: {(Payload iso)} iso) =>
    _respond = consume respond
    _request = request

    var response: Payload iso = Payload.response(StatusOK)
    response.update("Content-type", "application/json")

    let url = StangURL.create(_request.url)
    // url(1) is "_matrix" and url(2) is "client"
    match url(3)
      | "versions" => response.add_chunk("{\"versions\": [\"r0.2.0\"]}")
    else
      response = Payload.response(StatusNotFound)
    end

    _respond(consume response)

