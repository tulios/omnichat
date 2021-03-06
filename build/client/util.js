(function() {
  var Util;
  Util = {
    replace_all: function(string, from, to) {
      var pos;
      pos = string.indexOf(from);
      while (pos > -1) {
        string = string.replace(from, to);
        pos = string.indexOf(from);
      }
      return string;
    },
    html_safe: function(string) {
      string = Util.replace_all(string, "<", "&lt;");
      string = Util.replace_all(string, ">", "&gt;");
      string = Util.replace_all(string, "\"", "&quot;");
      string = Util.replace_all(string, "'", "&#x27;");
      return string = Util.replace_all(string, "/", "&#x2F;");
    }
  };
}).call(this);
