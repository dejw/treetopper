require "lib/treetopper/version"
$gem = Gem::Specification.new do |s|
  s.name = "treetopper"
  s.version = Treetopper::Version::STRING
  s.author = "Dawid Fatyga"
  s.email = "dawid.fatyga@gmail.com"
  s.homepage = "http://github.com/dejw/treetopper/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Converter for EBNF grammar into .treetop file format."
  s.files = ["README.markdown", "Rakefile", "LICENSE", "{lib,bin,examples}/**/*"].map{|p| Dir[p]}.flatten
  s.bindir = "bin"
  s.executables = ["tott"]
  s.require_path = "lib"
  s.has_rdoc = false
  s.required_ruby_version = '>= 1.8.1'
  s.add_dependency "treetop", ">= 1.2.6"
end

