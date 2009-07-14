#!/usr/bin/env ruby

=begin rdoc
	* One grammar rule per line.

	Todo:
		* Special directives:
			* grammar :name	(the file name is the grammar name for default)
			* Aliases.
			* Inlining.
			* Including.
		* Removal of same productions.
		* Write it using TreeTop itself.
		* Some command line options.
=end

class Array
	def join_with(method, pattern = "")
		return join(pattern) unless method
		return "" if self.length == 0
		output = self[0].send(method)
		for i in (1...self.length)
			output += pattern + self[i].send(method)
		end
		output
	end
end

class Hash
	def join_with(method, pattern = "")
		self.values.join_with(method, pattern)
	end
end

class Error < Exception
end

class Symbol
	def to_tt
		self.to_s
	end
end

class String
	def to_tt
		"'#{self}'"
	end
end

class Numeric
	def to_tt
		"'#{self.to_s}'"
	end
end

class Array
	def to_tt
		@sequence.join_with(:to_tt, " ")
	end
end

class Echo
	def initialize(value)
		@value = value
	end
	def to_tt
		@value
	end
end

class Production
	PREFIX = '    '

	attr_accessor :class_name, :block
	def initialize(sequence, options = {})
		sequence = Echo.new(sequence) unless sequence.respond_to? :to_ary
		@sequence = sequence
		@class_name = options[:class_name]
		@block = options[:block]
	end

	def to_tt
		output = @sequence.to_tt
		raise Error.new("Production < #{output} > can't has both class_name and block attribute.") if @class_name and @block
		output += " <#{@class_name}>" if @class_name
		output += " {\n\n#{PREFIX}}" if @block
		PREFIX + output + "\n"
	end
end

class Rule
	PREFIX = '  '
	attr_accessor :name, :productions
	def initialize(name)
		@name = name
		@productions = []
	end

	def to_tt
		PREFIX + "rule #{@name}\n" + @productions.join_with(:to_tt, "#{Production::PREFIX}/\n") + "#{PREFIX}end\n"
	end

	def add(p)
		@productions.push(Production.new(p))
	end
end

class Grammar
	def initialize(name = nil)
		@grammar_name = name || "Grammar"
		@rules = {}
	end

	def to_tt
		"grammar #{@grammar_name}\n" + @rules.join_with(:to_tt, "\n") + "end"
	end

	def [](rule)
		@rules[rule] ||= Rule.new(rule)
	end
end

module Parser
	def self.parse(content, name = nil)
		grammar = Grammar.new(name)
		content.each_line do |line|
			line.strip!
			next if line == "" or line.match(/^\#.*/)
			rule, prods = line.split("->")
			raise Error("Malformed rule.") if rule == line or prods == ""
			rule.strip
			prods.split("|").each do |p|
				p.strip!
				raise Error("Production cannot be empty.") if p == ""
				grammar[rule].add(p.squeeze(" "))
			end
		end
		grammar.to_tt
	end

	def self.parse_file(name)
		File.open(name) do |file|
			parse(file.read, File.basename(name).split(".")[0])
		end
	end
end

g = %{
	S -> a | b
	S -> b
}

puts Parser.parse(g)

puts Parser.parse_file("examples/dyck.ebnf")
