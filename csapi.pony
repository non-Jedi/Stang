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

trait CSApi
  be apply(responder: Responder val)

actor R0 is CSApi
  be apply(responder: Responder val) =>
    let response = Payload.response(StatusNotFound)
    responder.respond(consume response)

actor Versions is CSApi
  be apply(responder: Responder val) =>
    let response = Payload.response(StatusOK)
    response.add_chunk("{\"versions\":[\"r0.2.0\"]}")
    responder.respond(consume response)

class val ApiCollection
  let r0: R0 tag
  let versions: Versions tag

  new val create() =>
    r0 = R0.create()
    versions = Versions.create()
