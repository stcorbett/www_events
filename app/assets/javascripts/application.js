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

  // click the radio button that is already selected so the interface opens
  $('input[name=event\\[event_recurrence\\]]:checked').click()



  $('.event_time_inputs .time').timepicker({
      'showDuration': true,
      'timeFormat': 'g:iA',
      'step': '15',
      'scrollDefault': "12:00PM",
  });

  // initialize datepair
  $('.event_time_inputs').datepair();

  $(".event_time_inputs input.time.start[date_pair_value]").each(function( index ){
    var input = $(this)
    var value = input.attr("date_pair_value").replace(/\s/g, '');
    input.timepicker('setTime', value)

    input.trigger("change.datepair");
  });

  $(".event_time_inputs input.time.end[date_pair_value]").each(function( index ){
    var input = $(this)
    var value = input.attr("date_pair_value").replace(/\s/g, '');
    input.timepicker('setTime', value)

    input.trigger("change.datepair");
  });
  

  // initialize multiple day event inputs
  $('.event_time_inputs .sunday.start.time').timepicker({'disableTimeRanges': [['12:01PM', '11:59PM']], 'scrollDefault': "10:00AM", 'maxTime': "12:01PM"});
  $('.event_time_inputs .sunday.end.time').timepicker({'disableTimeRanges': [['12:01PM', '11:59PM']], 'maxTime': "12:01PM"});

});
