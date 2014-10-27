// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require jquery.timepicker
//= require Datepair
//= require jquery.datepair
//= require bootstrap-datepicker
//= require scripts
//= require_tree .

$(document).ready(function(){

  $("#event_event_recurrence_single").click(function () {    
    $("#single_occurrance_event").show();
    $("#multiple_occurrance_event").hide();
  });

  $("#event_event_recurrence_multiple").click(function () {    
    $("#single_occurrance_event").hide();
    $("#multiple_occurrance_event").show();
  });

  // show/hide depending on what's clicked already on page load



  $('.event_time_inputs .time').timepicker({
      'showDuration': true,
      'timeFormat': 'g:iA'
  });

  $('.event_time_inputs .date').datepicker({
      'startDate': '6-17-2015',
      'endDate': '6-21-2015',
      'format': 'm-d-yyyy',
      'autoclose': true
  });

  // initialize datepair
  $('.event_time_inputs').datepair();
  

});
