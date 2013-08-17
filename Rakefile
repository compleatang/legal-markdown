# -*- encoding: utf-8 -*-

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc "Run all RSpec test examples"
task :spec do
  RSpec::Core::RakeTask.new do |spec|
    spec.rspec_opts = ["-c", "-f progress"]
    spec.pattern = 'spec/**/*_spec.rb'
  end
end

desc "Update Sublime Package"
task :sublime do
  begin
    tag = LegalMarkdown::VERSION
  rescue
    require Dir.pwd + "/lib/legal_markdown/version.rb"
    tag = LegalMarkdown::VERSION
  end
  Dir.chdir(File.dirname(__FILE__))
  pkg = ENV['HOME'] + "/sites/sublime/Legal Document Creator"
  FileUtils.cp_r( File.dirname(__FILE__) + "/lib" , pkg )
  Dir.chdir(pkg)
  f = "lib/legal_markdown.rb"
  c = File::read(f) + "\n\nLegalMarkdown::parse(ARGV)"
  File.open(f, "w") { |f| f.write( c ); f.close }
  message = "Package updated at reflect changes in Gem to version #{tag}."
  system "git add -A"
  system "git commit -m #{message.shellescape}"
  system "git push github master"
  system "git push wsl master"
  Dir.chdir(File.dirname(__FILE__))
end

desc "Publish New Version of Gem & Update Sublime Package"
task :publish do
  fail "Does not look like the Version file is updated!" unless `git status -s`.split("\n").include?(" M lib/legal_markdown/version.rb")
  require Dir.pwd + "/lib/legal_markdown/version.rb"
  tag = LegalMarkdown::VERSION
  system "git checkout master"
  system "git add -A"
  system "git commit -m 'Version Bump of Gem to version #{tag}'"
  system "git tag -a v" + tag
  system "git push github master --tags"
  system "git push wsl master --tags"
  system "rake install"
  system "gem push pkg/legal_markdown-#{tag}.gem"
  Rake::Task["build"].invoke
  system "google-chrome https://github.com/compleatang/legal-markdown/releases"
end

task :default => :spec