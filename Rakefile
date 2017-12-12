require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::ExtensionTask.new "ccurl" do |ext|
  ext.lib_dir = "lib"
end

def can_compile_extensions
  return false if RUBY_DESCRIPTION =~ /jruby/
  return true
end

if can_compile_extensions
  task :default => [:compile, :test]
else
  task :default => [:test]
end
