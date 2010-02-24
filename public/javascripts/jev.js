if(typeof Intranet == "undefined") {
  var Intranet = {};
}

// Duplicate the given input form, remove its value,
// and insert it after the original
Intranet.dupInputForm = function(elem) {
  var orig = elem;
  var dup = orig.clone();

  // fix its html value
  var html = dup.html();
  html = html.replace(/value="(.*)"/, "value=\"\"");
  html = html.replace(/(\d+)/g, function(m,n) { return Number(n) + 1; });
  dup.html(html);

  dup.insertAfter(orig);
}

// remove the given input form
// unless it is the last one
Intranet.removeInputForm = function(elem) {
  if(elem.prev().hasClass("separator") && elem.next().hasClass("action")) {
    // can't remove the last one ! let's just clear the value
    var html = elem.html();
    html = html.replace(/value="(.*)"/, "value=\"\"");
    elem.html(html);
    return;
  }
  elem.remove();
}

$(document).ready(function() {
  $.getJSON('/account.json', function(user) {
    Intranet.current_user = user;
    $('#intranet').trigger('current_user-loaded');
  });
});

