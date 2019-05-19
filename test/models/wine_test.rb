require 'test_helper'

class WineTest < ActiveSupport::TestCase
  test "wine with no producer" do
    wine = Wine.new(domain: 'Test', color: colors(:one),
                    region: regions(:one), provider: providers(:one))
    assert wine.save
  end

  test "wine with no provider" do
    wine = Wine.new(domain: 'Test', color: colors(:one),
                    region: regions(:one), producer: producers(:one))
    assert wine.save
  end
end
