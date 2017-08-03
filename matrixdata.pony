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
use "regex"

class iso MatrixData
  """
  Class to encapsulate the json returned by a matrix server.
  """
  var data: JsonDoc iso

  new iso create(data': JsonDoc iso) =>
    data = consume data'

  fun ref mangle(find: Regex, mangle_text: String val) ? =>
    """
    For now this just looks for instances of the regex within the string
    representation of the json, but in the future, it will actually traverse
    the json document, allowing usage of `^` and `$` in regular expressions.

    For now, `find` must not match on the localparts containing `~`

    An exception is raised if unable to parse new string as json.
    """
    let original_string = data.string()
    let new_string = try
      let rmatch = find(original_string) ?
      let s: String iso = original_string.clone()
      s.insert_in_place(ISize.from[USize](rmatch.start_pos()) + 1, "~" + mangle_text + "~")
      consume s
    else
      // If we can't find regex in string, return original string, and recur end
      original_string
    end

    // If unable to parse string as json, raise an exception
    let replaced_data = recover iso JsonDoc.create() end
    replaced_data.parse(new_string) ?
    data = consume replaced_data
    if not (new_string is original_string) then
      mangle(find, mangle_text) ?
    end
