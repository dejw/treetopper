=begin rdoc
	Defines implemented extensions standard Ruby classes.
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

	def to_tt
		@sequence.join_with(:to_tt, " ")
	end
end

class Hash
	def join_with(method, pattern = "")
		self.values.join_with(method, pattern)
	end
end

class String
	def to_tt
		"#{self}"
	end
end
