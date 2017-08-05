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

use "json"
use "ponytest"
use "package:../src"

class iso _TestMatrixDataMangle is UnitTest
  let input: String val =
    "{
      \"next_batch\": \"s72595_4483_1934\",
      \"presence\": {
        \"events\": [
          {
            \"sender\": \"@alice:example.com\",
            \"type\": \"m.presence\",
            \"content\": {\"presence\": \"online\"}
          }
        ]
      }"
  let output: String val =
    "{
      \"next_batch\": \"s72595_4483_1934\",
      \"presence\": {
        \"events\": [
          {
            \"sender\": \"@~test~alice:example.com\",
            \"type\": \"m.presence\",
            \"content\": {\"presence\": \"online\"}
          }
        ]
      }"

  fun name(): String => "MatrixData.mangle"
  fun box apply(h: TestHelper) =>
    let j = try
      let jd = JsonDoc.create()
      jd.parse(input) ?
      consume jd
    else
      let jd = JsonDoc.create()
      consume jd
    end
    let m: MatrixData = MatrixData.create(consume j)
    try
      m.mangle("@", "test") ?
    end
    h.assert_eq[String](m.data.string(), output)
