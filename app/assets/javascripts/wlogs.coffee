# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
})

get_info = () ->
    $('#spinner').show();
    brid = $('#bottle_rack_id').val()
    if brid == ''
        $('#RackAjax').html("")
    else
        wlogid = $('#wlog_id').val()
        if $('#move_in_phase').length > 0
          move_in_phase = true
        else
          move_in_phase = false
        $('#RackAjax').load("/bottle_racks/#{brid}/get_info", {wlog_id: wlogid, id: brid, move_in_phase: move_in_phase })
    $('#spinner').hide();

$(document).ready ->
    $('#bottle_rack_id').change ->
        get_info()
