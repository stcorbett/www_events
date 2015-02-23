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


  // events can start at midnight, end at the next midnight

  var timepicker_defaults = {
                              'showDuration': true,
                              'timeFormat': 'g:iA',
                              'step': '15',
                              'scrollDefault': "12:00PM",
                              'minTime': "12:00AM",
                            }

  $('.event_time_inputs .start.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'showDuration': false,
                                      }
            )
  );
  $('.event_time_inputs .end.time').timepicker(timepicker_defaults);

  // initialize multiple day event inputs
  // events can't start before LOF or end afterwards
  $('.event_time_inputs .wednesday.start.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'showDuration': false,
                                        'minTime': "10:00AM",
                                        'disableTimeRanges': [['12:00AM', '09:59AM']],
                                      }
            )
  );
  $('.event_time_inputs .wednesday.end.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'disableTimeRanges': [['12:00AM', '09:59AM']],
                                      }
            )
  );

  $('.event_time_inputs .sunday.start.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'showDuration': false,
                                        'minTime': "12:00AM",
                                        'maxTime': "12:01PM",
                                        'disableTimeRanges': [['12:01PM', '11:59PM']],
                                        'scrollDefault': "10:00AM",
                                      }
            )
  );
  $('.event_time_inputs .sunday.end.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'maxTime': "12:01PM",
                                        'disableTimeRanges': [['12:01PM', '11:59PM']],
                                        'scrollDefault': "10:00AM",
                                      }
            )
  );

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
  

});
