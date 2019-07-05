require 'test_helper'

class BottleRacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bottle_rack = bottle_racks(:one)
  end

  test "should get index" do
    get bottle_racks_url
    assert_response :success
  end

  test "should get new" do
    get new_bottle_rack_url
    assert_response :success
  end

  test "should create bottle_rack" do
    assert_difference('BottleRack.count') do
      post bottle_racks_url, params: { bottle_rack: { columns: @bottle_rack.columns, lines: @bottle_rack.lines, name: @bottle_rack.name } }
    end

    assert_redirected_to bottle_rack_url(BottleRack.last)
  end

  test "should show bottle_rack" do
    get bottle_rack_url(@bottle_rack)
    assert_response :success
  end

  test "should get edit" do
    get edit_bottle_rack_url(@bottle_rack)
    assert_response :success
  end

  test "should update bottle_rack" do
    patch bottle_rack_url(@bottle_rack), params: { bottle_rack: { columns: @bottle_rack.columns, lines: @bottle_rack.lines, name: @bottle_rack.name } }
    assert_redirected_to bottle_rack_url(@bottle_rack)
  end

  test "should destroy bottle_rack" do
    assert_difference('BottleRack.count', -1) do
      delete bottle_rack_url(@bottle_rack)
    end

    assert_redirected_to bottle_racks_url
  end
end
