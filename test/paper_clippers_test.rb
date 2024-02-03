require_relative "test_helper"

require "tmpdir"

class PaperClippersTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::PaperClippers.const_defined?(:VERSION)
    end
  end

  test "clip method should save node content to file" do
    # Prepare test data
    html_path = File.expand_path("fixtures/test.html", __dir__)
    xpath = "//div[@class='content']"
    range_str = nil
    output_dir = Dir.mktmpdir

    # Create a PaperClipper instance
    clipper = PaperClipper.new(html_path, xpath, range_str, output_dir)

    # Call the clip method
    clipper.clip

    # Verify the file is created and contains the expected content
    expected_content = "Lorem ipsum dolor sit amet\n"
    file_path = File.join(output_dir, "divclasscontent.txt")
    assert File.exist?(file_path)
    assert_equal expected_content, File.read(file_path)

    # Clean up
    FileUtils.rm_r(output_dir)
  end
end
