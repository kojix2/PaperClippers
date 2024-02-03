require "optparse"
require "paper_clippers"

class PaperClipper
  class CommandLine
    def initialize
      @options = {}

      OptionParser.new do |opts|
        opts.banner = "kirinuki [options]"
        opts.separator ""
        opts.separator "Example: ruby kirinuki.rb -f 'path/to/your.html' -p '//*[@id=\"sec数\"]' -r '1..12'"
        opts.on("-f", "--file HTML_PATH", "HTML file path") { |v| @options[:file] = v }
        opts.on("-p", "--pattern PATTERN", "Pattern") { |v| @options[:pattern] = v }
        opts.on("-r", "--range RANGE", "Range") { |v| @options[:range] = v }
        opts.on("-o", "--output OUTPUT_DIR", "Output directory") { |v| @options[:output] = v }
      end.parse!
    end

    def run
      clipper = PaperClipper.new(@options[:file], @options[:pattern], @options[:range], @options[:output])
      clipper.execute
    rescue StandardError => e
      warn(e.message)
      exit 1
    end
  end
end
