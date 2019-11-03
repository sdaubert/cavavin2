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


    add_wines = (el) ->
        region_wines_ul = $(el).children('ul.region-wines')
        if !region_wines_ul.length
            # No ul.region-wines. Hav to get it from server
            href = $(el).children('a').attr('href')
            color_id = $(el).parent().attr('id').match(/color-(\d+)/)[1]
            $(el).append("<ul class=\"region-wines\" style=\"display:none;\"></ul>")
            region_wines_ul = $(el).children('ul.region-wines')
            region_wines_ul.load("#{href}/wine_list_by_color", { color_id: color_id }, ->
                $(el).mouseleave()
                $(el).mouseenter())

        if region_wines_ul.children().length
            region_wines_ul.slideDown()

    remove_wines = (el) ->
        $(el).children('ul.region-wines').slideUp()

    $(".association dd ul li").hover ->
        if $(this).hasClass('wines-got')
            remove_wines(this)
        else
            add_wines(this)
        $(this).toggleClass('wines-got')

    true
