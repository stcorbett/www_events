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

  $(".btn-all-events").click(function () {
    $(".not-your-event").show();
    $(".active").removeClass('active');
    $(".btn-all-events").addClass("active")
  });

  $(".btn-your-events").click(function () {
    $(".not-your-event").hide();
    $(".active").removeClass('active');
    $(".btn-your-events").addClass("active")
  });

  var new_event_id = getUrlParameter('new_event');
  if (new_event_id) {
    $(".event-" + new_event_id).addClass("bg-info");
    $(".event-" + new_event_id).css({margin: "5px auto", "padding-top": "10px", "padding-bottom": "10px"});
    $(".btn-your-events").click();
  }

});

$(document).ready(function(){

  wednesday_time_disable = "11:59AM"
  wednesday_start_time = "12:00PM"
  sunday_end_time = "3:00PM"
  sunday_time_disable = "3:01PM"

  $(".all_day_event").click(function () {
    var checkbox = $(this);
    var form_row = checkbox.closest(".event_time_inputs");
    var start_input = form_row.find(".start")
    var end_input = form_row.find(".end")
    var date = form_row.find(".day_of_week_input")

    if (checkbox.prop( "checked" )) {
      start_input.prop('readonly', true);
      end_input.prop('readonly', true);

      if (checkbox.closest("#single_occurrance_event").length > 0) {
        date.after("<label class='hidden_select_replacement'>" + date.val() + ":</label>")
        date.hide()
      }

      start_input.data("manual_selection", start_input.val())
      end_input.data("manual_selection", end_input.val())

      start_input.timepicker('setTime', "12:00AM")
      end_input.timepicker('setTime', "12:00AM")

      if (date.val() == "Wednesday"){
        start_input.timepicker('setTime', wednesday_start_time)
      }
      if (date.val() == "Sunday"){
        end_input.timepicker('setTime', sunday_end_time)
      }
    } else {
      start_input.prop('readonly', false);
      end_input.prop('readonly', false);
      date.show()
      $(".hidden_select_replacement").remove()
      // unhide date, remove print

      start_input.timepicker('setTime', start_input.data("manual_selection"))
      start_input.trigger("change.datepair");
      end_input.timepicker('setTime', end_input.data("manual_selection"))
      end_input.trigger("change.datepair");
    }
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
                                        'minTime': wednesday_start_time,
                                        'disableTimeRanges': [['12:00AM', wednesday_time_disable]],
                                      }
            )
  );
  $('.event_time_inputs .wednesday.end.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'disableTimeRanges': [['12:00AM', wednesday_time_disable]],
                                      }
            )
  );

  $('.event_time_inputs .sunday.start.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'showDuration': false,
                                        'minTime': "12:00AM",
                                        'maxTime': sunday_time_disable,
                                        'disableTimeRanges': [[sunday_time_disable, '11:59PM']],
                                        'scrollDefault': "10:00AM",
                                      }
            )
  );
  $('.event_time_inputs .sunday.end.time').timepicker(
    $.extend({}, timepicker_defaults, {
                                        'maxTime': sunday_time_disable,
                                        'disableTimeRanges': [[sunday_time_disable, '11:59PM']],
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

function getUrlParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) 
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) 
        {
            return sParameterName[1];
        }
    }
}   