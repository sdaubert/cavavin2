require 'test_helper'

class RegionsControllerTest < ActionController::TestCase
  setup do
    @country = countries(:one)
    @region = regions(:one)
  end

  test "should get index" do
    get :index, params: { country_id: @country }
    assert_response :success
  end

  test "should get new" do
    get :new, params: { country_id: @country }
    assert_response :success
  end

  test "should create region" do
    assert_difference('Region.count') do
      post :create, params: { country_id: @country, region: @region.attributes }
    end

    assert_redirected_to country_region_path(@country, Region.last)
  end

  test "should show region" do
    get :show, params: { country_id: @country, id: @region }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { country_id: @country, id: @region }
    assert_response :success
  end

  test "should update region" do
    put :update, params: { country_id: @country, id: @region, region: @region.attributes }
    assert_redirected_to country_region_path(@country, Region.last)
  end

  test "should destroy region" do
    assert_difference('Region.count', -1) do
      delete :destroy, params: { country_id: @country, id: @region }
    end

    assert_redirected_to country_regions_path(@country)
  end
end
