# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
})

get_to_be_processed = () ->
  $('#to-be-processed').text() * 1

handle_submit = () ->
  console.log('enter handle_submit')
  to_be_processed = get_to_be_processed()
  if isNaN(to_be_processed)
    console.log('NaN:' + $('#to-be-processed').text())
    return

  console.log('process submit:' + to_be_processed + ',' + $('table').length)
  submit = $('input[type="submit"]')
  if (to_be_processed == 0) || ($('table').length == 0)
    submit.prop('disabled', false)
  else
    submit.prop('disabled', true)

checkbox_clicked = (cb) ->
  to_be_processed = get_to_be_processed()
  if isNaN(to_be_processed)
    return

  if $(cb).prop('checked')
    $('#to-be-processed').text(to_be_processed - 1)
  else
    $('#to-be-processed').text(to_be_processed + 1)

  handle_submit()

set_check_box_onclick = () ->
  $('input[type="checkbox"]').off('click')
  $('input[type="checkbox"]').click ->
    checkbox_clicked(this)

get_info = (complete_cb) ->
  $('#spinner').show();
  brid = $('#bottle_rack_id').val()
  if brid == ''
    $('#RackAjax').html("")
    complete_cb()
  else
    wlogid = $('#wlog_id').val()
    if $('#move_in_phase').length > 0
      move_in_phase = true
    else
      move_in_phase = false
    $('#RackAjax').load("/bottle_racks/#{brid}/get_info", {wlog_id: wlogid, id: brid, move_in_phase: move_in_phase }, complete_cb)
    set_check_box_onclick()
  $('#spinner').hide()

$(document).ready ->
  $('#bottle_rack_id').off('change')
  $('#bottle_rack_id').change ->
    get_info ->
      set_check_box_onclick()
      handle_submit()

