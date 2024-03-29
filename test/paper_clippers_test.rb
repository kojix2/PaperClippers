require_relative "test_helper"
require "tmpdir"

class PaperClippersTest < Test::Unit::TestCase
  def setup
    @html_path = File.expand_path("fixtures/test.html", __dir__)
    @output_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_r(@output_dir)
  end

  def test_VERSION
    assert do
      ::PaperClippers.const_defined?(:VERSION)
    end
  end

  def test_initialize_with_uri_scheme_should_strip_file_scheme
    html_path = "file://#{File.expand_path('fixtures/test.html', __dir__)}"
    xpath = "//div[@class='summary']"
    clipper = PaperClippers.new(html_path, xpath, nil, nil, @output_dir, nil)
    assert_equal File.expand_path("fixtures/test.html", __dir__), clipper.instance_variable_get(:@html_path)
  end

  def test_clip_method_should_save_node_content_to_file_without_range_using_xpath
    xpath = "//div[@class='summary']"
    clipper = PaperClippers.new(@html_path, xpath, nil, nil, @output_dir, nil)
    clipper.clip

    expected_contents = "Summary\n" \
                        "     \n" \
                        "This is a summary of the paper.\n"
    file_path = File.join(@output_dir, "divclasssummary.txt")
    assert File.exist?(file_path)
    assert_equal expected_contents, File.read(file_path)
  end

  def test_clip_method_should_save_node_content_to_file_with_range_using_xpath
    xpath = "//div[@class='sec指']"
    range_str = "1..2"
    replace_str = "指"
    output_file = "out指.txt"

    clipper = PaperClippers.new(@html_path, xpath, range_str, output_file, @output_dir, replace_str)
    clipper.clip

    expected_contents = [
      "Lorem ipsum dolor sit amet\n",
      "consectetur adipiscing elit\n"
    ]

    expected_contents.each_with_index do |expected_content, index|
      file_path = File.join(@output_dir, "out#{index + 1}.txt")
      assert File.exist?(file_path)
      assert_equal expected_content, File.read(file_path)
    end
  end

  def test_clip_method_should_save_node_content_to_file_without_range_using_css_selector
    css_selector = ".summary"
    clipper = PaperClippers.new(@html_path, css_selector, nil, nil, @output_dir, nil, selector_type: :css)
    clipper.clip

    expected_contents = "Summary\n" \
                        "     \n" \
                        "This is a summary of the paper.\n"
    file_path = File.join(@output_dir, "summary.txt")
    assert File.exist?(file_path)
    assert_equal expected_contents, File.read(file_path)
  end

  def test_clip_method_should_save_node_content_to_file_with_range_using_css_selector
    css_selector = "div.sec指"
    range_str = "1..2"
    replace_str = "指"
    output_file = "out指.txt"

    clipper = PaperClippers.new(@html_path, css_selector, range_str, output_file, @output_dir, replace_str,
                                selector_type: :css)
    clipper.clip

    expected_contents = [
      "Lorem ipsum dolor sit amet\n",
      "consectetur adipiscing elit\n"
    ]

    expected_contents.each_with_index do |expected_content, index|
      file_path = File.join(@output_dir, "out#{index + 1}.txt")
      assert File.exist?(file_path)
      assert_equal expected_content, File.read(file_path)
    end
  end
end
