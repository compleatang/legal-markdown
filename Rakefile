require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test*.rb']
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

# call with rake site:publish
desc "Publish New Version of Gem"
task :pushit do
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
  Dir.chdir(File.dirname(__FILE__))
  pkg = ENV['HOME'] + "/.config/sublime-text-2/Packages/Legal Document Creator"
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
  system "google-chrome https://github.com/compleatang/legal-markdown/releases"
end

task :default => [:test]