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

class val StangURL
  let source: URL box

  new val create(url: URL val) =>
    source = url

  fun box apply(i: USize val): String box =>
    try
      source.path.split(where delim="/")(i) ?
    else
      ""
    end

class val Responder
  """
  Convenience class for grouping stuff needed to respond to a request.
  """
  let request: Payload val
  let respond: {(Payload iso)} iso
  let url: StangURL val

  new val create(request': Payload val, respond':{(Payload iso)} iso) =>
    request = request'
    respond = consume respond'
    url = StangURL.create(request.url)
