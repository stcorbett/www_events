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
      'timeFormat': 'g:iA',
      'step': '15',
      'scrollDefault': "12:00PM",
  });

  $('.event_time_inputs .date').datepicker({
      'startDate': '6-17-2015',
      'endDate': '6-21-2015',
      'format': 'm-d-yyyy',
      'autoclose': true
  });

  // initialize datepair
  $('.event_time_inputs').datepair();

  // initialize multiple day event inputs
  $('#event_wednesday_start_date').datepicker('setDate', '06-17-2015');
  $('#event_thursday_start_date').datepicker('setDate', '06-18-2015');
  $('#event_friday_start_date').datepicker('setDate', '06-19-2015');
  $('#event_saturday_start_date').datepicker('setDate', '06-20-2015');
  $('#event_sunday_start_date').datepicker('setDate', '06-21-2015');

  $('#event_sunday_start_time').timepicker({'disableTimeRanges': [['12:01PM', '11:59PM']], 'scrollDefault': "10:00AM", 'maxTime': "12:01PM"});
  $('#event_sunday_end_time').timepicker({'disableTimeRanges': [['12:01PM', '11:59PM']], 'maxTime': "12:01PM"});

});
