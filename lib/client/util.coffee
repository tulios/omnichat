Util = {
  replace_all: (string, from, to) ->
    pos = string.indexOf(from);
    while pos > -1
      string = string.replace(from, to)
      pos = string.indexOf(from)

    string

  html_safe: (string) ->
    string = Util.replace_all(string, "<", "&lt;")
    string = Util.replace_all(string, ">", "&gt;")
    string = Util.replace_all(string, "\"", "&quot;")
    string = Util.replace_all(string, "'", "&#x27;")
    string = Util.replace_all(string, "/", "&#x2F;")
}