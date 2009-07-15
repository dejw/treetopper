#!/usr/bin/env ruby

=begin rdoc
	Todo:
		* Special directives:
			* Inlining.
			* Including.
		* Removal of same productions.
		* Write it using TreeTop itself.
		* Some command line options.
=end

require "lib/grammar"

module Treetopper
	# Standard treetopper error definition.
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

	def fail(msg, number = nil)
		raise Error.new(msg, number)
	end

	def assert(expr, msg, number = nil)
		fail(msg, number) unless expr
	end

	class Parser
		include Treetopper

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
			Treetopper.fail("at line #{number}: " + e.to_s)
		end

		def parse_file(name)
			File.open(name) do |file| begin
				parse(file.read, File.basename(name).split(".")[0])
			rescue Error => e
				fail("in file #{name} " + e.to_s)
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
	end
end

g = %{
	:grammar Simple
	:alias S myRule
	S -> a | b
	S -> b
}

if $0 == __FILE__
	include Treetopper
	begin
		puts Parser.parse(g)
		puts Parser.parse_file("examples/dyck.ebnf")
	rescue Error => e
		$stderr.puts "error " + e.message
end
end

