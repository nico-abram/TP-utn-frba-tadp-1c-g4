	
class Trait
	attr_accessor :methodHash
	attr_accessor :methodToCreateAlias

	def self.copy(trait)
		copiedTrait = Trait.new
		copiedTrait.methodHash = trait.methodHash.clone
		copiedTrait
	end
	
	def self.create()
		trait = Trait.new
		trait.methodHash = Hash.new
		trait
	end
	
	def self.define(&bloque)
		trait = Trait.create
		trait.instance_eval(&bloque)
	end

	def name(sym)
		Object.const_set(sym, self)
	end

	# Agregar el metodo sym con el codigo bloque
	def method(sym, &bloque)
		methodHash[sym] = bloque
	end

	def estrategiaDefault(proc1, proc2)
		return Proc.new { |*args| 
		  raise "Unresolved trait method conflict"
		}
	end

	def +(traitASumar)
		nuevoTrait = Trait.create
		self.methodHash.each do |sym, bloque|
			nuevoTrait.methodHash[sym] = bloque
		end
		traitASumar.methodHash.each do |sym, bloque|
			if nuevoTrait.methodHash.has_key? sym
				nuevoTrait.methodHash[sym] = estrategiaDefault(self.methodHash[sym], bloque)
			else
				nuevoTrait.methodHash[sym] = bloque
			end
		end
		nuevoTrait
	end

	def -(sym) #sym es el metodo a restar
		nuevoTrait = Trait.copy self
		nuevoTrait.methodHash.delete sym
		nuevoTrait
	end
	
	def <<(sym) #metodo al que crear alias
		nuevoTrait = Trait.copy self
		nuevoTrait.methodToCreateAlias = sym
		nuevoTrait
	end
	
	def >(sym) #nombre del alias
		nuevoTrait = Trait.copy self
		if @methodToCreateAlias != nil
			nuevoTrait.methodHash[sym] = methodHash[@methodToCreateAlias]
			nuevoTrait.methodToCreateAlias = nil
		# else exception?
		end
		nuevoTrait
	end
end


class Class
	def uses(traitObj)
		traitObj.methodHash.each do |sym, bloque|
			self.send(:define_method, sym, &bloque)
		end
	end
end

Trait.define do
	name :A
	method :h do
		"H"
	end
end

class B uses A end
# B.new.h