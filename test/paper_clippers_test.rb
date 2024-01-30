# frozen_string_literal: true

require "test_helper"

class PaperClippersTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::PaperClippers.const_defined?(:VERSION)
    end
  end
end
