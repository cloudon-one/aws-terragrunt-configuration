{
  "lookup_nested": "function(map, path) { result = map; for key in split('.', path) { result = try(result[key], null); if (result == null) { return null; } } return result; }"
}