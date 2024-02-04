require "optparse"
require_relative "../paper_clippers"

class PaperClipper
  class CommandLine
    def initialize
      @options = {
        html_path: nil,
        selector: nil,
        selector_type: :xpath, # デフォルトは :xpath とする
        range_str: nil,
        replace_str: "{}",
        output_dir: nil
      }

      @parser = OptionParser.new do |opts|
        opts.banner = "Usage: kirinuki [options]"
        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  kirinuki -f 'path/to/your.html' -x '//*[@id=\"sec{}\"]' -r '1..12'"
        opts.separator "  kirinuki -f 'path/to/your.html' -c '.section' -o 'output_dir'"

        opts.on("-f", "--file HTML_PATH", "HTML file path") { |v| @options[:html_path] = v }
        opts.on("-x", "--xpath XPATH", "XPath (exclusive with --css)") do |v|
          @options[:selector] = v
          @options[:selector_type] = :xpath
        end
        opts.on("-c", "--css CSS", "CSS Selector (exclusive with --xpath)") do |v|
          @options[:selector] = v
          @options[:selector_type] = :css
        end
        opts.on("-r", "--range RANGE", "Range") { |v| @options[:range_str] = v }
        opts.on("-o", "--outdir OUTPUT_DIR", "Output directory") { |v| @options[:output_dir] = v }
        opts.on("-I", "--replace STRING", "Replace string [default: #{@options[:replace_str]}]") do |v|
          @options[:replace_str] = v
        end
      end

      @parser.parse!
      validate_options!
    end

    def run
      clipper = PaperClipper.new(@options[:html_path], @options[:selector], @options[:range_str], @options[:output_dir],
                                 @options[:replace_str], selector_type: @options[:selector_type])
      clipper.clip
    rescue StandardError => e
      warn(@parser)
      warn("\n[kirinuki] Error: #{e.message} (#{e.class}) (#{e.backtrace.first})")
      exit 1
    end

    private

    def validate_options!
      return unless @options[:html_path].nil? || @options[:selector].nil?

      warn(@parser)
      exit 1
    end
  end
end
