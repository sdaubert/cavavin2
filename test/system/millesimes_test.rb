require "application_system_test_case"

class MillesimesTest < ApplicationSystemTestCase
  setup do
    @millesime = millesimes(:one)
  end

  test "visiting the index" do
    visit millesimes_url
    assert_selector "h1", text: "Millesimes"
  end

  test "creating a Millesime" do
    visit millesimes_url
    click_on "New Millesime"

    fill_in "Garde", with: @millesime.garde
    fill_in "Notes", with: @millesime.notes
    fill_in "Wine", with: @millesime.wine_id
    fill_in "Year", with: @millesime.year
    click_on "Create Millesime"

    assert_text "Millesime was successfully created"
    click_on "Back"
  end

  test "updating a Millesime" do
    visit millesimes_url
    click_on "Edit", match: :first

    fill_in "Garde", with: @millesime.garde
    fill_in "Notes", with: @millesime.notes
    fill_in "Wine", with: @millesime.wine_id
    fill_in "Year", with: @millesime.year
    click_on "Update Millesime"

    assert_text "Millesime was successfully updated"
    click_on "Back"
  end

  test "destroying a Millesime" do
    visit millesimes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Millesime was successfully destroyed"
  end
end
