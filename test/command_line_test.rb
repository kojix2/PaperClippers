require_relative "test_helper"
require_relative "../lib/paper_clippers/command_line"
require "tmpdir"
require "stringio"

class PaperClippersCommandLineTest < Test::Unit::TestCase
  def setup
    @output_dir = Dir.mktmpdir
    @stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    FileUtils.rm_r(@output_dir)
    $stdout = @stdout
  end

  def test_run_method_should_call_clip_method_of_PaperClipper
    html_path = File.expand_path("fixtures/test.html", __dir__)
    selector = "//*[@class='summary']"

    command_line = PaperClipper::CommandLine.new
    command_line.parse_args(["-f", html_path, "-x", selector, "-o", @output_dir])
    command_line.clip

    assert(File.exist?(File.join(@output_dir, "classsummary.txt")))

    expected = "Summary\n     \nThis is a summary of the paper.\n"

    assert_equal(expected, File.read(File.join(@output_dir, "classsummary.txt")))
  end
end
