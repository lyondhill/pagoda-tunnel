require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour --format documentation']
end

desc "Create tag v#{Pagoda::Tunnel::VERSION}"
task :tag do
  
  puts "tagging version v#{Pagoda::Tunnel::VERSION}"
  `git tag -a v#{Pagoda::Tunnel::VERSION} -m "Version #{Pagoda::Tunnel::VERSION}"`
  `git push origin --tags`
  
end
