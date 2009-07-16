ROOT = File.join(File.dirname(__FILE__), 'treetopper')
["version", "extensions", "grammar", "parser"].each do |file|
	require File.join(ROOT, file)
end
