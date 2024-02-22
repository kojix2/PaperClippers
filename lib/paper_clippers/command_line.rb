require "optparse"
require "colorize"
require_relative "../paper_clippers"

class PaperClippers
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
    end

    def parse_args(args = ARGV)
      @parser = OptionParser.new do |opts|
        opts.banner = <<~BANNER
          kirinuki - HTML content clipper

          Usage: kirinuki [options]
        BANNER
        opts.separator ""
        opts.separator "Examples:".colorize(:green)
        opts.separator "  kirinuki -f 'path/to/your.html' -x '//*[@id=\"sec{}\"]' -r '1..12'".colorize(:light_white)
        opts.separator "  kirinuki -f 'path/to/your.html' -c '.section' -o 'output_dir'".colorize(:light_white)

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
        opts.on("-o", "--outdir [OUTPUT_DIR]", "Output directory") do |v|
          @options[:output_dir] = (v || File.basename(@options[:html_path], ".*"))
        end
        opts.on("-I", "--replace STRING", "Replace string [default: #{@options[:replace_str]}]") do |v|
          @options[:replace_str] = v
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
        opts.on("-v", "--version", "Prints version information") do
          puts "kirinuki #{PaperClippers::VERSION}"
          exit
        end
      end

      @parser.parse!(args)
      validate_options!
    end

    def run
      parse_args
      clip
    rescue StandardError => e
      warn(@parser)
      warn("\n[kirinuki] Error: #{e.message} (#{e.class})".colorize(:red))
      exit 1
    end

    def clip
      clipper = PaperClippers.new(@options[:html_path], @options[:selector], @options[:range_str], @options[:output_dir],
                                  @options[:replace_str], selector_type: @options[:selector_type])
      file_paths = clipper.clip
      if file_paths.empty?
        warn("[kirinuki] #{'No content found for the given selector.'.colorize(:red).bold}")
      else
        puts("[kirinuki] #{'Clipped content has been saved to the following files:'.colorize(:green)}")
        puts(file_paths.map { |fp, nt| "\t#{nt}\t#{fp}".colorize(:light_white) }.join("\n"))
      end
    end

    private

    def validate_options!
      return unless @options[:html_path].nil? || @options[:selector].nil?

      warn(@parser)
      exit 1
    end
  end
end
