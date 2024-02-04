require "nokogiri"
require "fileutils"
require_relative "paper_clippers/version"

class PaperClipper
  def initialize(html_path, selector, range_str = nil, output_dir = nil, replace_str = nil, selector_type: :xpath)
    @html_path = html_path
    @selector = selector
    @selector_type = selector_type # :xpath or :css
    @range_str = range_str
    @replace_str = replace_str
    @output_dir = output_dir || Dir.pwd
  end

  def clip
    doc = Nokogiri::HTML(File.open(@html_path))
    range = @range_str ? eval(@range_str) : [nil]
    file_paths = []

    range.each do |i|
      modified_selector = if @replace_str && i
                            @selector.gsub(@replace_str, i.to_s)
                          else
                            @selector
                          end

      nodes = case @selector_type
              when :css
                doc.css(modified_selector)
              when :xpath
                doc.xpath(modified_selector)
              else
                raise "Unsupported selector type: #{@selector_type}"
              end

      file_paths << nodes.map { |node| save_node_content(node.inner_html, modified_selector) }
    end
    file_paths.flatten
  end

  private

  def save_node_content(html, selector)
    html = format_html(html)
    file_name = selector.gsub(/[^0-9A-Za-z_]/, "")
    file_path = File.join(@output_dir, "#{file_name}.txt")

    FileUtils.mkdir_p(@output_dir)
    File.open(file_path, "a") { |f| f.puts html }

    file_path
  end

  def format_html(html)
    html.gsub!(/\R|\t/, " ")
    html.gsub!(/<(h[1-6]|p|li|dd)/, "\n\\0")
    html.gsub!(%r{</(h[1-6]|p|li|dd)>}, "\\0\n")
    Nokogiri::HTML(html).text.strip
  end
end
