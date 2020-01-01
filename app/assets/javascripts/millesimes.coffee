# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
    disable= (id) ->
        label = $("label[for='#{id}']")
        el = $("##{id}")
        el.prop('disabled', true)
        el.addClass('muted')
        label.prop('disabled', true)
        label.addClass('muted')

    enable= (id) ->
        label = $("label[for='#{id}']")
        el = $("##{id}")
        el.prop('disabled', false)
        el.removeClass('muted')
        label.prop('disabled', false)
        label.removeClass('muted')

    $("#millesime_void_millesime").change ->
        if this.checked
            disable("millesime_year")
            disable("millesime_garde")
        else
            enable("millesime_year")
            enable("millesime_garde")
