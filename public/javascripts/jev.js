if(typeof Intranet == "undefined") {
  var Intranet = {};
}

// work in progress
Intranet.form = function() {
  var orig = $('#mydiv');
  var dup = orig.clone();
  var html = dup.html();
  html = html.replace(/my_id/g, "new id");
  dup.html(html);
  dup.insertAfter(orig);
}

$(document).ready(function() {
  $.getJSON('/account.json', function(user) {
    Intranet.current_user = user;
    $('#intranet').trigger('current_user-loaded');
  });
});

