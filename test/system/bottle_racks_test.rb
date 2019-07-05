require "application_system_test_case"

class BottleRacksTest < ApplicationSystemTestCase
  setup do
    @bottle_rack = bottle_racks(:one)
  end

  test "visiting the index" do
    visit bottle_racks_url
    assert_selector "h1", text: "Bottle Racks"
  end

  test "creating a Bottle rack" do
    visit bottle_racks_url
    click_on "New Bottle Rack"

    fill_in "Columns", with: @bottle_rack.columns
    fill_in "Lines", with: @bottle_rack.lines
    fill_in "Name", with: @bottle_rack.name
    click_on "Create Bottle rack"

    assert_text "Bottle rack was successfully created"
    click_on "Back"
  end

  test "updating a Bottle rack" do
    visit bottle_racks_url
    click_on "Edit", match: :first

    fill_in "Columns", with: @bottle_rack.columns
    fill_in "Lines", with: @bottle_rack.lines
    fill_in "Name", with: @bottle_rack.name
    click_on "Update Bottle rack"

    assert_text "Bottle rack was successfully updated"
    click_on "Back"
  end

  test "destroying a Bottle rack" do
    visit bottle_racks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bottle rack was successfully destroyed"
  end
end
