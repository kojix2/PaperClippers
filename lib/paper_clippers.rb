require "nokogiri"
require "fileutils"
require "tiktoken_ruby"
require_relative "paper_clippers/version"

class PaperClippers
  def initialize(html_path, selector, range_str = nil, output_file = nil, output_dir = nil, replace_str = nil, selector_type: :xpath,
                 model: "gpt-4")
    @html_path = html_path.delete_prefix("file://")
    @selector = selector
    @selector_type = selector_type # :xpath or :css
    @range_str = range_str
    @replace_str = replace_str
    warn "[kirinuki] No range specified" if @replace_str && @selector.include?(@replace_str) && @range_str.nil?
    @output_file = output_file
    @output_dir = output_dir || Dir.pwd
    @enc = Tiktoken.encoding_for_model(model)
  end

  def clip
    doc = Nokogiri::HTML(File.open(@html_path))
    range = @range_str ? eval(@range_str) : [nil]
    file_paths = []

    range.each do |i|
      modified_selector = \
        if @replace_str && i
          @selector.gsub(@replace_str, i.to_s)
        else
          @selector
        end
      file_name = \
        if @output_file && @replace_str && i
          @output_file.gsub(@replace_str, i.to_s)
        elsif @output_file
          @output_file
        else
          modified_selector.gsub(/[^0-9A-Za-z_]/, "") + ".txt"
        end

      nodes = case @selector_type
              when :css
                doc.css(modified_selector)
              when :xpath
                doc.xpath(modified_selector)
              else
                raise "Unsupported selector type: #{@selector_type}"
              end

      file_paths << nodes.map { |node| save_node_content(node.inner_html, file_name) }
    end
    file_paths.flatten(1)
  end

  private

  def save_node_content(html, file_name)
    content = format_html(html)
    ntokens = count_tokens(content)

    file_path = File.join(@output_dir, file_name)

    FileUtils.mkdir_p(@output_dir)
    File.open(file_path, "a") { |f| f.puts content }

    [file_path, ntokens]
  end

  def format_html(html)
    html.gsub!(/\R|\t/, " ")
    html.gsub!(/<(h[1-6]|p|li|dd)/, "\n\\0")
    html.gsub!(%r{</(h[1-6]|p|li|dd)>}, "\\0\n")
    Nokogiri::HTML(html).text.strip
  end

  def count_tokens(text)
    @enc.encode(text).length
  end
end
