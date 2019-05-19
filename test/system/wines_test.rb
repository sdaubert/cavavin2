require "application_system_test_case"

class WinesTest < ApplicationSystemTestCase
  setup do
    @wine = wines(:one)
  end

  test "visiting the index" do
    visit wines_url
    assert_selector "h1", text: "Wines"
  end

  test "creating a Wine" do
    visit wines_url
    click_on "New Wine"

    fill_in "Color", with: @wine.color_id
    fill_in "Domain", with: @wine.domain
    check "Effervescent" if @wine.effervescent
    fill_in "Garde", with: @wine.garde
    fill_in "Notes", with: @wine.notes
    check "Organic" if @wine.organic
    fill_in "Producer", with: @wine.producer_id
    fill_in "Provider", with: @wine.provider_id
    fill_in "Region", with: @wine.region_id
    click_on "Create Wine"

    assert_text "Wine was successfully created"
    click_on "Back"
  end

  test "updating a Wine" do
    visit wines_url
    click_on "Edit", match: :first

    fill_in "Color", with: @wine.color_id
    fill_in "Domain", with: @wine.domain
    check "Effervescent" if @wine.effervescent
    fill_in "Garde", with: @wine.garde
    fill_in "Notes", with: @wine.notes
    check "Organic" if @wine.organic
    fill_in "Producer", with: @wine.producer_id
    fill_in "Provider", with: @wine.provider_id
    fill_in "Region", with: @wine.region_id
    click_on "Update Wine"

    assert_text "Wine was successfully updated"
    click_on "Back"
  end

  test "destroying a Wine" do
    visit wines_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wine was successfully destroyed"
  end
end
