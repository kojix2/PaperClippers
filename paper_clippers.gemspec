# frozen_string_literal: true

require_relative "lib/paper_clippers/version"

Gem::Specification.new do |spec|
  spec.name = "paper_clippers"
  spec.version = PaperClippers::VERSION
  spec.authors = ["kojix2"]
  spec.email = ["2xijok@gmail.com"]

  spec.summary = "Crop papers from local HTML"
  spec.description = "Crop papers from local HTML"
  spec.homepage = "https://github.com/kojix2/PaperClippers"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir["*.{md,txt}", "{lib,exe,prompts}/**/*"]
  spec.bindir = "exe"
  spec.executables = "kirinuki"
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize"
  spec.add_dependency "nokogiri"
  spec.add_dependency "tiktoken_ruby"
end
