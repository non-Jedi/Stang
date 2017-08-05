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

class ref MatrixData
  """
  Class to encapsulate the json returned by a matrix server.
  """
  var data: JsonDoc ref

  new ref create(data': JsonDoc iso) =>
    data = consume data'

  fun ref mangle(mx_sigil: String val, mangle_text: String val) ? =>
    /*TODO: change api of this function to make it matrix-specific. This
    shouldn't have a regex as an input argument but construct one itself from
    a given string(s)*/

    """
    Mangles matrix identifiers starting with any character in `mx_sigil` so that
    there won't be collisions if a user is in the same room on multiple
    accounts. "~`mangle_text`~" is inserted into the matrix_identifier after the
    sigil.

    For now this simply searches and replaces within the string representation
    of the json document, but traversing the document itself will be implemented
    eventually.

    `mangle_text` must match the regex expression `^[a-zA-Z0-9]+$`

    An exception is raised if unable to parse new string as json or if
    `mangle_text` doesn't match the above regex expression. When traversing the
    json document is implemented, this exception will be raised purely based on
    the correctness of the arguments passed in.
    """
    // This block checks input formats; regex compiling shouldn't raise error
    let okay = try
      let r_mangle_text = Regex("^[a-zA-Z0-9]+$") ?
      let r_mx_sigil = Regex("^[!#@+$]$") ?
      (r_mangle_text == mangle_text) and (r_mx_sigil == mx_sigil)
    else
      false
    end
    if not okay then
      error
    end

    let insert_text = "~" + mangle_text + "~"
    let re_all = Regex("\"[" + mx_sigil + "][^\\s\"'~]+:[^\\s\"']+\"") ?

    let json_string: String iso = data.string().clone()
    // Find instances of regular expression until there are no more
    var val_string = ""
    var stop = false
    repeat
      stop = try
        val_string = recover val json_string.clone() end
        let rmatch: Match = re_all(val_string) ?
        json_string.insert_in_place(ISize.from[USize](rmatch.start_pos()) + 2, insert_text)
        false
      else
        true
      end
    until stop end

    let new_data = recover ref JsonDoc.create() end
    new_data.parse(consume json_string) ?
    data = new_data

  fun ref unmangle(mx_sigil: String val) ? =>
    // TODO
    error
