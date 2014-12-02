require "bundler/gem_tasks"

desc "Run an IRB session with BOS preloaded"
task :console do
  exec "irb -I lib -r bos"
end

require 'rake/testtask'

task :default => :test

task :test do
  require "bos"
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
