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
//= require jquery-ui/widgets/autocomplete
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
    $(".row.event").show();

    $(".active").removeClass('active');
    $(".btn-all-events").addClass("active")
  });

  $(".btn-your-events").click(function () {
    $(".row.event").show();
    $(".not-your-event").hide();

    $(".active").removeClass('active');
    $(".btn-your-events").addClass("active")
  });

  $(".btn-hearted-events").click(function () {
    $(".row.event").show();
    $(".not-hearted").hide();

    $(".active").removeClass('active');
    $(".btn-hearted-events").addClass("active")
  });

  $(document).on("click", ".not-hearted .heart-click",function() {
    $(this).parents(".not-hearted").addClass("hearted");
    $(this).parents(".not-hearted").removeClass('not-hearted');

    var eventId = $(this).attr("event-time-id");
    $.ajax({
      url: "/heart",
      data: { id: eventId }
    }).done(function( msg ) {
    });
  });

  $(document).on("click", ".hearted .heart-click",function() {
    $(this).parents(".hearted").addClass("not-hearted");
    $(this).parents(".hearted").removeClass('hearted');

    var eventId = $(this).attr("event-time-id");
    $.ajax({
      url: "/unheart",
      data: { id: eventId }
    }).done(function( msg ) {
    });
  });

  var hash = window.location.hash.substr(1)
  if (hash.length > 0) {
    switch(hash) {
    case "hearted":
      $(".btn-hearted-events").trigger("click");
      break;
    case "yours":
      $(".btn-your-events").trigger("click");
      break;
    }
  }

  $(document).on("click", "a.printable-link", function(e) {
    e.preventDefault();

    var hash = window.location.hash
    var destination = '/print';
    if (hash.length > 0) {
      destination = destination + hash
    }

    window.location = destination
  });

  $(".edit-location").click(function (e) {
    e.preventDefault();

    $(".opening-message").hide();
    $("#edit-location").show();

    camp = $(this);
    $("form#edit-location #location_hosting_location").val(camp.data("hosting-location"));
    $("form#edit-location #location_site_id").val(camp.data("site-id"));

    $("form#edit-location #location_original_hosting_location").val(camp.data("hosting-location"));
    $("form#edit-location #location_original_site_id").val(camp.data("site-id"));
    $("h4 .location-name").html(camp.data("hosting-location"));
    $("h4 .location-name").addClass("text-success");
    $(".location").removeClass("text-success");
    camp.parents(".location").addClass("text-success");

    $("form#edit-location #location_hosting_location").focus();
    $("form#edit-location #location_hosting_location").select();
    $("#edit-location-panel").scrollIntoViewBelowNav(false);
  });

  var new_event_id = getUrlParameter('new_event');
  if (new_event_id) {
    $(".event-" + new_event_id).addClass("bg-info");
    $(".event-" + new_event_id).css({margin: "5px auto", "padding-top": "10px", "padding-bottom": "10px"});
    $(".btn-your-events").click();
  }

  var hosting_location_tag = getUrlParameter('updated_location');
  if (hosting_location_tag) {
    var updated_location = $("[data-location-tag='" + hosting_location_tag + "']");
    if (updated_location.length) {
      updated_location.find(".edit-location").click();
      updated_location.scrollIntoViewBelowNav();
    }
  }

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


jQuery.fn.extend({
  scrollIntoViewBelowNav: function (scroll_in_wide_screens) {
    if (scroll_in_wide_screens == undefined){
      scroll_in_wide_screens = true
    }

    this[0].scrollIntoView();

    if( $(window).width() < 769 ){
      window.scrollBy(0, -200);
    } else if(scroll_in_wide_screens) {
      window.scrollBy(0, -50);
    }
  }
});
