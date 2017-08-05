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
use "regex"
use "json"

trait CSApi
  be apply(responder: Responder val)

  fun box map_room_refs(data: JsonDoc iso, to_stang: Bool box) ? =>
    let mdata = MatrixData.create(consume data)

    if to_stang then
      mdata.mangle("!#", "example") ?
    else
      mdata.unmangle("!#") ?
    end

    consume mdata

actor R0 is CSApi
  be apply(responder: Responder val) =>
    let response = match responder.url(4)
      // Special cases requiring special handling
      | "sync" => Payload.response(StatusNotImplemented)
      | "login" => Payload.response(StatusNotImplemented)
      | "tokenrefresh" => Payload.response(StatusNotImplemented)
      | "logout" => Payload.response(StatusNotImplemented)
      | "register" => Payload.response(StatusNotImplemented)
      | "account" => Payload.response(StatusNotImplemented)
    else
      // Pass request on to servers more or less as is
      Payload.response(StatusNotFound)
    end
    responder.respond(consume response)

actor Versions is CSApi
  be apply(responder: Responder val) =>
    let response = Payload.response(StatusOK)
    response.update("Content-type", "application/json")
    response.add_chunk("{\"versions\":[\"r0.2.0\"]}")
    responder.respond(consume response)

class val ApiCollection
  let r0: R0 tag
  let versions: Versions tag

  new val create() =>
    r0 = R0.create()
    versions = Versions.create()
