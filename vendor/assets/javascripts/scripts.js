$(document).ready(function(){/* jQuery toggle layout */

$('#btnToggle').click(function(){
  if ($(this).hasClass('on')) {
    $('#main .col-md-6').addClass('col-md-4').removeClass('col-md-6');
    $(this).removeClass('on');
  }
  else {
    $('#main .col-md-4').addClass('col-md-6').removeClass('col-md-4');
    $(this).addClass('on');
  }
});

// Initialize tooltips - Bootstrap 3 way was: $('[data-toggle="tooltip"]').tooltip({delay: { "show": 300 }})
// Bootstrap 5 vanilla JS way:
document.addEventListener('DOMContentLoaded', function () {
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl, {
      delay: { "show": 100, "hide": 0 }
    });
  });
});

// Popover
// http://getbootstrap.com/javascript/#popovers

});