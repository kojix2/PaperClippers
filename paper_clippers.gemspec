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

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
end
