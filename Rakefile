require 'rubygems'
require 'rake'
require "rake/gempackagetask"

task :default => :gem

load "./treetopper.gemspec"

Rake::GemPackageTask.new($gem) do |pkg|
  pkg.need_tar = true
end
