rebuildId = (id) ->
  return "#{id[0..7]}-#{id[8..11]}-#{id[12..15]}-#{id[16..19]}-#{id[20..31]}"

module.exports = rebuildId
