require "optparse"
require_relative "paper_clippers" # better to use relative as it requires less path lookup

class PaperClipper
  class CommandLine
    def initialize
      @options = {}

      OptionParser.new do |opts|
        opts.banner = "kirinuki [options]"
        opts.separator ""
        opts.separator "Example: ruby kirinuki.rb -f 'path/to/your.html' -p '//*[@id=\"sec数\"]' -r '1..12'"
        opts.on("-f", "--file HTML_PATH", "HTML file path") { |v| @options[:html_path] = v }
        opts.on("-p", "--pattern PATTERN", "Pattern") { |v| @options[:pattern] = v }
        opts.on("-r", "--range RANGE", "Range") { |v| @options[:range_str] = v } # variable names should match
        # variable names should match
        opts.on("-o", "--output OUTPUT_DIR", "Output directory") do |v|
          @options[:output_dir] = v
        end
      end.parse!
    end

    def run
      # use of keyword arguments
      clipper = PaperClipper.new(@options)
      clipper.clip # renaming execute to clip is more appropriate in this case
    rescue StandardError => e
      warn(e.message)
      exit 1
    end
  end
end
