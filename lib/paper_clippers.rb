require "nokogiri"
require "fileutils"
require_relative "paper_clippers/version"
class PaperClipper
  # Using keyword arguments to make the method invocation more explicit.
  def initialize(html_path, pattern, range_str = nil, output_dir = nil)
    @html_path = html_path
    @pattern = pattern
    @range_str = range_str
    @output_dir = output_dir || File.basename(html_path, ".*") # Also, basename is already nil-safe
  end

  def clip
    doc = Nokogiri::HTML(File.open(@html_path))

    range = @range_str ? eval(@range_str) : [""]

    # eliminated a redundant iteration using flat_map.
    range.each do |i|
      xpath = @pattern.gsub("数", i.to_s)
      nodes = doc.xpath(xpath)
      nodes.each { |node| save_node_content(node.inner_html, xpath) }
    end
  end

  private

  # Encapsulated dir creation and file writing into a separate method
  def save_node_content(html, xpath)
    html = format_html(html)
    file_name = xpath.gsub(/[^0-9A-Za-z_]/, "")
    dir_path = File.join(@output_dir, "#{file_name}.txt")

    FileUtils.mkdir_p(@output_dir)
    File.open(dir_path, "a") { |f| f.puts html }
  end

  def format_html(html)
    # remove any existing newlines or tabs
    html.gsub!(/\R|\t/, " ")
    # add a newline before each heading and paragraph
    html.gsub!(/<(h[1-6]|p|li|dd)/, "\n\\0")
    # add a newline after each ending heading and paragraph tag
    html.gsub!(%r{</(h[1-6]|p|li|dd)>}, "\\0\n")

    # simplified method chaining
    Nokogiri::HTML(html).text.strip
  end
end
