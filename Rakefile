require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Push the Gem & Update Sublime Package"
task :publish do
  system "git push github master"
  system "git push wsl master"
  Dir.chdir(File.dirname(__FILE__))
  pkg = ENV['HOME'] + "/.config/sublime-text-2/Packages/Legal Document Creator"
  FileUtils.cp_r( File.dirname(__FILE__) + "/lib" , pkg )
  Dir.chdir(pkg)
  f = "lib/legal_markdown.rb"
  c = File::read(f) + "\n\nLegalMarkdown::parse(ARGV)"
  File.open(f, "w") { |f| f.write( c ); f.close }
  message = "Package updated at #{Time.now.utc} to reflect changes in Gem."
  system "git add -A"
  system "git commit -m #{message.shellescape}"
  system "git push github master"
  system "git push wsl master"
  Dir.chdir(File.dirname(__FILE__))
end

task :default => [:test]