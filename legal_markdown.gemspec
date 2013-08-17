# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'legal_markdown/version'

Gem::Specification.new do |s|
  s.name              = "legal_markdown"
  s.version           = LegalMarkdown::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Gem for parsing legal documents written in markdown for processing with legal specific requirements."
  s.homepage          = "http://github.com/compleatang/legal-markdown"
  s.email             = "caseykuhlman@watershedlegal"
  s.authors           = [ "Casey Kuhlman" ]
  s.has_rdoc          = false

  s.files             = `git ls-files`.split($/)
  s.executables       = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files        = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths     = ["lib"]
  s.license           = 'MIT'

  s.add_dependency('paint')
  s.add_development_dependency('rspec')
  s.add_development_dependency('coveralls')

  s.description       = <<desc
  This gem will parse YAML Front Matter of Markdown Documents. Typically, this gem would be called with a md renderer, such as Pandoc, that would turn the md into a document such as a .pdf file or a .docx file. By combining this pre-processing with a markdown renderer, you can ensure that both the structured content and the structured styles necessary for your firm or organization are more strictly enforced. Plus you won't have to deal with Word any longer, and every lawyer should welcome that. Why? Because Word is awful.
desc
end