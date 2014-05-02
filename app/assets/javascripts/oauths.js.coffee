# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


Oauth = {}
Oauth.ready = ->
  console.log("Oauth.ready")
  if $("#oauths.new").length || $("#oauths.edit").length
    checkers = $(".checker")
    checkers.each ->
      if $(this).find("input").val()=="1"
        $(this).addClass("checked")
    checkers.on "mousedown", ->
      checker = $(this)
      v = $(this).find("input").val()
      Oauth.toggleChecker($(this), v)
      checkers.on "mouseenter", ->
        Oauth.toggleChecker($(this), v)
      $("body").on "mouseup", ->
        checkers.off "mouseenter"
Oauth.toggleChecker = (j,c)->
  if c=="1"
    j.removeClass("checked")
    j.find("input").val(0)
  else
    j.addClass("checked")
    j.find("input").val(1)
  Oauth.setCheckerStr(j)
Oauth.setCheckerStr = (j)->
  input = j.find("input")
  name = input.attr("name")
  name_body = name.replace("[]","")
  str = ""
  $("input[name='#{name}']").each ->
    str += $(this).val()
  $("input[name='#{name_body}_str']").val(str)

$(document).ready(Oauth.ready)
$(document).on('page:load', Oauth.ready)