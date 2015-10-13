# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  pop = $(".popbtn")
  row = $(".row:not(:first):not(:last)")
  pop.popover
    trigger: "manual"
    html: true
    container: "body"
    placement: "bottom"
    animation: false
    content: ->
      $("#popover").html()

  pop.on "click", (e) ->
    pop.popover "toggle"
    pop.not(this).popover "hide"

  $(window).on "resize", ->
    pop.popover "hide"

  row.on "touchend", (e) ->
    $(this).find(".popbtn").popover "toggle"
    row.not(this).find(".popbtn").popover "hide"
    false

  $(".btn-convert-vids").click ->
    $.ajax
      url: "/cart/convert_videos"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
       $('body').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        alert 'success'