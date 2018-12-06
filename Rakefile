require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

if RUBY_PLATFORM =~ /java/
  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new "jcurl" do |ext|
    ext.lib_dir = "lib"
  end
else
  require 'rake/extensiontask'
  Rake::ExtensionTask.new "ccurl" do |ext|
    ext.lib_dir = "lib"
  end
end

task :default => [:compile, :test]
