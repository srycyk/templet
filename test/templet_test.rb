require "test_helper"

class TempletTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Templet::VERSION
  end
end
