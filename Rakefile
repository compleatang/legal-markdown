require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Push the Gem & Update Sublime Package"
task :generate do
  # system "git push github master"
  # system "git push wsl master"
  Dir.chdir(File.dirname(__FILE__))
  pkg = "/home/coda/.config/sublime-text-2/Packages/Legal\\ Document\\ Creator/"
  system "cp lib #{pkg} -R"
  system "cd #{pkg}"
  f = Dir.pwd + "/lib/legal_markdown.rb"
  c = File::read(f) + "\n\nLegalMarkdown::parse(ARGV)"
  p c
  File.open(f, "w") { |f| f.write( c ); f.close }
  message = "Package updated at #{Time.now.utc} to reflect changes in Gem."
  system "git add -A"
  system "git commit -m #{message.shellescape}"
  system "git push github master"
  system "git push wsl master"
  Dir.chdir(File.dirname(__FILE__))
end

# call with rake site:publish
desc "Generate and publish blog"
task :publish => [:generate] do
  Dir.chdir "_site"
  system "git add -A"
  message = "Site updated at #{Time.now.utc}"
  system "git commit -m #{message.shellescape}"
  system "git push origin master  --force"
  system "ssh 119629@git.dc0.gpaas.net 'deploy blog.caseykuhlman.com.git master'"
end

task :default => [:test]