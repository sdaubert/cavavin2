# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
    get_id =(el) ->
        check_id = $(el).attr('id')
        id = check_id.match(/region_(\d+)/)[1]

    expand = (el) ->
        $(".child-of-"+get_id(el)).show()

    collapse = (el) ->
        id = get_id(el)
        $(".child-of-"+id).children("td").removeClass("not-leaf-expanded")
        $(".child-of-"+id).hide()
        $(".subchild-of-"+id).children("td").removeClass("not-leaf-expanded")
        $(".subchild-of-"+id).hide()

    $(".not-leaf").click ->
        if $(this).hasClass('not-leaf-expanded')
            collapse(this)
        else
            expand(this)
        $(this).toggleClass('not-leaf-expanded')

    $(".not-root").hide()

    true
