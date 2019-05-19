require 'test_helper'

class MillesimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @millesime = millesimes(:one)
  end

  test "should get index" do
    get millesimes_url
    assert_response :success
  end

  test "should get new" do
    get new_millesime_url
    assert_response :success
  end

  test "should create millesime" do
    assert_difference('Millesime.count') do
      post millesimes_url, params: { millesime: { garde: @millesime.garde, notes: @millesime.notes, wine_id: @millesime.wine_id, year: @millesime.year } }
    end

    assert_redirected_to millesime_url(Millesime.last)
  end

  test "should show millesime" do
    get millesime_url(@millesime)
    assert_response :success
  end

  test "should get edit" do
    get edit_millesime_url(@millesime)
    assert_response :success
  end

  test "should update millesime" do
    patch millesime_url(@millesime), params: { millesime: { garde: @millesime.garde, notes: @millesime.notes, wine_id: @millesime.wine_id, year: @millesime.year } }
    assert_redirected_to millesime_url(@millesime)
  end

  test "should destroy millesime" do
    assert_difference('Millesime.count', -1) do
      delete millesime_url(@millesime)
    end

    assert_redirected_to millesimes_url
  end
end
