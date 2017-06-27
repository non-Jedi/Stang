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

    // Start the top server control actor.
    HTTPServer(
      auth,
      ListenHandler(env),
      BackendMaker.create(env),
      logger
      where service=service, host=host, limit=limit, reversedns=auth)
