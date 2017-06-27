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

actor Stang
  """
  This is where the matrix logic will begin. Probably here will be routing
  between the different api versions and then other actors will be spawned to do
  actual processing of the request.
  """

  new create(request: Payload val, respond: {(Payload iso)} iso) =>
    let response: Payload iso = Payload.response()
    response.update("Content-type", "application/json")
    response.add_chunk("{1: 2}")
    respond(consume response)
