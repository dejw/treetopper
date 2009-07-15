#!/usr/bin/env ruby

=begin rdoc
	* One grammar rule per line.

	Todo:
		* Special directives:
			* Inlining.
			* Including.
		* Removal of same productions.
		* Write it using TreeTop itself.
		* Some command line options.
=end

require "lib/extensions"

class Error < StandardError
	attr_reader :line
	def initialize(msg = nil, line = nil)
		super(msg)
		@line = line
	end

	def to_s
		(@line ? "at line #{@line} " : "") + super
	end
end

class Production
	PREFIX = '    '

	attr_accessor :class_name, :block
	def initialize(sequence, options = {})
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
	attr_accessor :name
	def initialize(name = nil)
		@name = name || "Grammar"
		@rules = {}
		@aliases = {}
	end

	def register_alias(number, rule, name)
		@aliases[rule] = { :line => number, :name => name }
	end

	def to_tt
		@aliases.each do |rule, value|
			raise Error.new("alias: rule '#{rule}' does not exist", value[:line]) unless @rules.has_key?(rule)
			@rules[rule].name = value[:name]
		end
		"grammar #{@name}\n" + @rules.join_with(:to_tt, "\n") + "end"
	end

	def [](rule)
		@rules[rule] ||= Rule.new(rule)
	end
end

class Parser
	def self.instance
		@parser ||= Parser.new
	end

	def self.parse(content, name = nil)
		instance.parse(content, name)
	end

	def self.parse_file(file)
		instance.parse_file(file)
	end

	def parse(content, name = nil)
		@number = 1
		@grammar = Grammar.new(name)
		content.each_line do |line|
			parse_line(line.strip)
			@number += 1
		end
		@grammar.to_tt
	rescue Error => e
		raise e if e.line
		raise Error.new("at line #{number}: " + e.to_s)
	end

	def parse_file(name)
		File.open(name) do |file| begin
			parse(file.read, File.basename(name).split(".")[0])
		rescue Error => e
			raise Error.new("in file #{name} " + e.to_s)
		end end
	end
private
	def parse_line(line)
		case line
		when "" then
		when /^\#.*/ then
		when /^:(.+)/ then
			parse_command($1.strip.split(/\s+/))
		when /^(.+)\s*->\s*(.+)/ then
			rule = $1.strip
			$2.split("|").each do |p|
				@grammar[rule].add(p.strip.squeeze(" "))
			end
		else
			fail("malformed rule")
		end
	end

	def parse_command(args)
		case args[0]
		when "grammar"
			assert(args.length == 2, "grammar: need one argument")
			@grammar.name = args[1]
		when "alias"
			assert(args.length == 3, "alias: need two arguments")
			@grammar.register_alias(@number, args[1], args[2])
		else
			fail("bad command name")
		end
	end

	def fail(msg)
		raise Error.new(msg)
	end

	def assert(expr, msg)
		fail(msg) unless expr
	end
end

g = %{
	:grammar Simple
	:alias S myRule
	S -> a | b
	S -> b
}

begin
	puts Parser.parse(g)
	puts Parser.parse_file("examples/dyck.ebnf")
rescue Error => e
	$stderr.puts "error " + e.message
end
