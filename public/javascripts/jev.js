if(typeof Intranet == "undefined") {
  var Intranet = {};
}

// Duplicate the given input form, remove its value,
// and insert it after the original
Intranet.dupInputForm = function(elem) {
  // if it's hidden (last one), just display it
  if(elem.hasClass("hide")) {
    elem.removeClass("hide");
    return;
  }

  // duplicate it
  var orig = elem;
  var dup = orig.clone();

  // and fix the html value
  var html = dup.html();
  html = html.replace(/value="(.*)"/, "value=\"\"");
  html = html.replace(/(\d+)/g, function(m,n) { return Number(n) + 1; });
  dup.html(html);

  dup.insertAfter(orig);
}

// remove the given input form
Intranet.removeInputForm = function(elem) {
  if(elem.prev().hasClass("separator") && elem.next().hasClass("action")) {
    // can't remove the last one ! let's just clear the value
    var html = elem.html();
    html = html.replace(/value="(.*)"/, "value=\"\"");
    elem.html(html);
    // and hide it
    elem.addClass("hide");
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

