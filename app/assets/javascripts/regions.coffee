# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


#toggle_active = () ->
#    $(this).parentElement.querySelector('.nested').classList.toggle('active')
#    $(this).classList.toggle('caret-down')

$(document).ready ->
    #togglers = $(".caret")
    #for toggler in togglers
    #    toggler.click ->
    #        $(this).toggleClass('caret-down')
    #        $(this).siblings('.nested').toggleClass('active')
    $(".caret").click ->
        $(this).toggleClass('caret-down')
        $(this).siblings('.nested').toggleClass('active')
    true

