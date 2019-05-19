require "application_system_test_case"

class WlogsTest < ApplicationSystemTestCase
  setup do
    @wlog = wlogs(:one)
  end

  test "visiting the index" do
    visit wlogs_url
    assert_selector "h1", text: "Wlogs"
  end

  test "creating a Wlog" do
    visit wlogs_url
    click_on "New Wlog"

    fill_in "Date", with: @wlog.date
    fill_in "Millesime", with: @wlog.millesime_id
    fill_in "Mvt type", with: @wlog.mvt_type
    fill_in "Notes", with: @wlog.notes
    fill_in "Price", with: @wlog.price
    click_on "Create Wlog"

    assert_text "Wlog was successfully created"
    click_on "Back"
  end

  test "updating a Wlog" do
    visit wlogs_url
    click_on "Edit", match: :first

    fill_in "Date", with: @wlog.date
    fill_in "Millesime", with: @wlog.millesime_id
    fill_in "Mvt type", with: @wlog.mvt_type
    fill_in "Notes", with: @wlog.notes
    fill_in "Price", with: @wlog.price
    click_on "Update Wlog"

    assert_text "Wlog was successfully updated"
    click_on "Back"
  end

  test "destroying a Wlog" do
    visit wlogs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wlog was successfully destroyed"
  end
end
