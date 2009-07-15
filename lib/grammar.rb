=begin rdoc
	Defines grammar accepted by Treetopper.
=end

require "lib/extensions"

module Treetopper
	class Production
		PREFIX = '    '

		attr_accessor :class_name, :block
		def initialize(grammar, sequence, options = {})
			unless sequence.respond_to? :to_ary
				sequence = sequence.split(/\s+/)
			end
			@sequence = sequence
			@class_name = options[:class_name]
			@block = options[:block]
			@grammar = grammar
		end

		def to_tt
			for i in (0...@sequence.length) do
				if @sequence[i].class == Symbol or (not @sequence[i].match(/'.*'/) and not @sequence[i].match(/".*"/))
					@sequence[i] = @grammar[@sequence[i]].name
				end
			end
			output = @sequence.to_tt
			raise Error.new("Production < #{output} > can't has both class_name and block attribute") if @class_name and @block
			output += " <#{@class_name}>" if @class_name
			output += " {\n\n#{PREFIX}}" if @block
			PREFIX + output + "\n"
		end
	end

	class Rule
		PREFIX = '  '
		attr_accessor :name, :productions
		def initialize(grammar, name)
			@name = name
			@productions = []
			@grammar = grammar
		end

		def to_tt
			PREFIX + "rule #{@name}\n" + @productions.join_with(:to_tt, "#{Production::PREFIX}/\n") + "#{PREFIX}end\n"
		end

		def add(p)
			@productions.push(Production.new(@grammar, p))
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
			"grammar #{@name}\n" + @rules.join_with(:to_tt, "\n") + "end\n"
		end

		def [](rule)
			@rules[rule] ||= Rule.new(self, rule)
		end
	end
end
