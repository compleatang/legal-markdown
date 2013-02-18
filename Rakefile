require "bundler/gem_tasks"

# begin
#   require "mg"
#   MG.new("legal_markdown.gemspec")
# rescue LoadError
#   nil
# end

# desc "Build standalone script"
# task :build => [ :standalone ]

# desc "Build standalone script"
# task :standalone => :load_legal_markdown do
#   require 'legal_markdown/standalone'
#   LegalMarkdown::Standalone.save('legalmd')
# end

# Rake::TaskManager.class_eval do
#   def remove_task(task_name)
#     @tasks.delete(task_name.to_s)
#   end
# end

# # Remove mg's install task
# Rake.application.remove_task(:install)

# desc "Install standalone script"
# task :install => :standalone do
#   prefix = ENV['PREFIX'] || ENV['prefix'] || '/usr/local'

#   FileUtils.mkdir_p "#{prefix}/bin"
#   FileUtils.cp "legalmd", "#{prefix}/bin"
# end