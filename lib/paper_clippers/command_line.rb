require "optparse"
require_relative "../paper_clippers"

class PaperClipper
  class CommandLine
    def initialize
      @options = {
        html_path: nil,
        xpath: nil,
        range_str: nil,
        replace_str: "数",
        output_dir: nil
      }

      @parser = OptionParser.new do |opts|
        opts.banner = "kirinuki [options]"
        opts.separator ""
        opts.separator "Example: ruby kirinuki.rb -f 'path/to/your.html' -x '//*[@id=\"sec数\"]' -r '1..12'"
        opts.on("-f", "--file HTML_PATH", "HTML file path") { |v| @options[:html_path] = v }
        opts.on("-x", "--xpath XPATH", "XPath") { |v| @options[:xpath] = v }
        opts.on("-r", "--range RANGE", "Range") { |v| @options[:range_str] = v } # variable names should match
        # variable names should match
        opts.on("-o", "--output OUTPUT_DIR", "Output directory") do |v|
          opts.on("-I", "--replace STRING", "Replace string [default: #{@options[:replace_str]}]") do |v|
            @options[:replace_str] = v
          end
          @options[:output_dir] = v
        end
      end

      @parser.parse!
    end

    def run
      clipper = PaperClipper.new(@options[:html_path], @options[:xpath], @options[:range_str], @options[:output_dir],
                                 @options[:replace_str])
      clipper.clip # renaming execute to clip is more appropriate in this case
    rescue StandardError => e
      warn(@parser)
      warn("\n[kirinuki] Error: #{e.message} (#{e.class}) (#{e.backtrace.first})")
      exit 1
    end
  end
end
