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
    xpath = "//div[@class='sec指']"
    range_str = "1..2"
    output_dir = Dir.mktmpdir
    replace_str = "指"

    # Create a PaperClipper instance
    clipper = PaperClipper.new(html_path, xpath, range_str, output_dir, replace_str)

    # Call the clip method
    clipper.clip

    # Verify the files are created and contain the expected content
    expected_contents = [
      "Lorem ipsum dolor sit amet\n",
      "consectetur adipiscing elit\n"
    ]

    expected_contents.each_with_index do |expected_content, index|
      file_path = File.join(output_dir, "divclasssec#{index + 1}.txt")
      assert File.exist?(file_path)
      assert_equal expected_content, File.read(file_path)
    end

    # Clean up
    FileUtils.rm_r(output_dir)
  end
end
