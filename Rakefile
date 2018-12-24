require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

if RUBY_PLATFORM =~ /java/
  if ENV['TRAVIS'].to_s.empty?
    puts "Will build JAVA extension"

    require 'rake/javaextensiontask'
    Rake::JavaExtensionTask.new "jcurl" do |ext|
      ext.lib_dir = "lib"
    end
  else
    puts "Not building jar or travis"
  end
else
  puts "Will build C extension"

  require 'rake/extensiontask'
  Rake::ExtensionTask.new "ccurl" do |ext|
    ext.lib_dir = "lib"
  end
end

task :default => [:compile, :test]
