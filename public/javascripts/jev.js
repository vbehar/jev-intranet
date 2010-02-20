if(typeof Intranet == "undefined") {
  var Intranet = {};
}

$(document).ready(function() {
  $.getJSON('/account.json', function(user) {
    Intranet.current_user = user;
    $('#current_user_name').html(user.name);
  });
});

