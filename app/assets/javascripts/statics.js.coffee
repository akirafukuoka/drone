# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



ready = ->
  console.log("ready")
  if $(".pagination .next a").length
    console.log("entry.length")
    console.log($(".entries .entry").length)
    if $(".entries .entry").length
      $.autopager({
        content:'.entries .entry',
        link:'.pagination .next a',
        start: ->
          $(".next_loader").addClass("show")
          $(".next_loader").preloader(false)
          $(".next_loader").preloader({color: "#ffe92e", border:4, r: 24})
        load: ->
          $(".next_loader").removeClass("show")
          $(".next_loader").preloader(false)
          if $(this).html() == undefined
            $(".next_loader").addClass("hide")
            $(".next_loader .footers").addClass("appear")
            if $(".subscribe_block").length >= 2
              $(".next_loader .subscribe_block").css("display","none")
              $.autopager(false)
      })
  resize = ->
    console.log("resize")
    center = Math.round($(window).width()/2)
    $(".account .memori").each ->
      offset = -parseInt($(this).data("hour"))*60-parseInt($(this).data("min"))
      $(this).css("background-position": "#{center+offset}px 0px")
      $(this).find(".pin").css("background-position": "#{center}px 0px")
  resize()
  $(window).off("resize", resize)
  $(window).on("resize", resize)



$(document).ready(ready)
$(document).on('page:load', ready)
