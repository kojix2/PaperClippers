require "nokogiri"
require "fileutils"

class PaperClipper
  def initialize(html_path, pattern, range_str, output_dir)
    @html_path = html_path
    @pattern = pattern
    @range_str = range_str
    @output_dir = output_dir || File.basename(html_path, ".*")

    raise "No 数 found. Please check the pattern." unless pattern.include? "数"
  end

  def execute
    doc = Nokogiri::HTML(open(@html_path))
    range = eval(@range_str)

    range.each do |i|
      xpath = @pattern.gsub("数", i.to_s)
      nodes = doc.xpath(xpath)

      # process each node
      nodes.each do |node|
        html = process_html(node.inner_html, xpath)
        file_name = xpath.gsub(/[^0-9A-Za-z_]/, "")

        FileUtils.mkdir_p(@output_dir)
        File.open("#{@output_dir}/#{file_name}.txt", "a") do |f|
          f.puts html
        end
      end
    end
  end

  private

  def process_html(html, _xpath)
    html.gsub!(/\R|\t/, " ") # remove any existing newlines or tabs
    html.gsub!(/<(h[1-6]|p|li|dd)/, "\n\\0") # add a newline before each heading and paragraph
    html.gsub!(%r{</(h[1-6]|p|li|dd)>}, "\\0\n") # add a newline after each ending heading and paragraph tag

    Nokogiri::HTML(html).text
  end
end
