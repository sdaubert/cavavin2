require 'test_helper'

class WlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wlog = wlogs(:one)
  end

  test "should get index" do
    get wlogs_url
    assert_response :success
  end

  test "should get new" do
    get new_wlog_url
    assert_response :success
  end

  test "should create wlog" do
    assert_difference('Wlog.count') do
      post wlogs_url, params: { wlog: { date: @wlog.date, millesime_id: @wlog.millesime_id, mvt_type: @wlog.mvt_type, notes: @wlog.notes, price: @wlog.price } }
    end

    assert_redirected_to wlog_url(Wlog.last)
  end

  test "should show wlog" do
    get wlog_url(@wlog)
    assert_response :success
  end

  test "should get edit" do
    get edit_wlog_url(@wlog)
    assert_response :success
  end

  test "should update wlog" do
    patch wlog_url(@wlog), params: { wlog: { date: @wlog.date, millesime_id: @wlog.millesime_id, mvt_type: @wlog.mvt_type, notes: @wlog.notes, price: @wlog.price } }
    assert_redirected_to wlog_url(@wlog)
  end

  test "should destroy wlog" do
    assert_difference('Wlog.count', -1) do
      delete wlog_url(@wlog)
    end

    assert_redirected_to wlogs_url
  end
end
