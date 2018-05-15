
class Trait
	attr_accessor :methodHash
	attr_accessor :methodToCreateAlias
	attr_accessor :estrategias

	def self.copy(trait)
		copiedTrait = Trait.new
		copiedTrait.methodHash = trait.methodHash.clone
		copiedTrait
	end

	def self.create()
		trait = Trait.new
		trait.methodHash = Hash.new
		trait.estrategias = Hash.new
		trait
	end
	
	def self.define(&bloque)
		trait = Trait.create
		trait.instance_eval(&bloque)
	end

	def name(sym)
		Object.const_set(sym, self)
	end

	alias_method :get_method, :method
	# Agregar el metodo sym con el codigo bloque
	def method(sym, &bloque)
		methodHash[sym] = bloque
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
		else
			raise "Attempt to create alias with undefined alias name"
		end
		nuevoTrait
	end
	
	def sumar(traitASumar, estrategia, &bloque)
		nuevoTrait = Trait.create
		self.methodHash.each do |sym, proc|
			nuevoTrait.methodHash[sym] = proc
		end
		traitASumar.methodHash.each do |sym, proc|
			if nuevoTrait.methodHash.has_key? sym
				estrategiaAUsar = estrategia
				estrategiaAUsar = estrategias[sym] if estrategias[sym]
				estrategiaAUsar = traitASumar.estrategias[sym] if traitASumar.estrategias[sym]
				nuevoTrait.methodHash[sym] = estrategia.call(self.methodHash[sym], proc, &bloque)
			else
				nuevoTrait.methodHash[sym] = proc
			end
		end
		nuevoTrait
	end

	def +(traitASumar)
		sumar(traitASumar, Proc.new{ |proc_1, proc_2|
			Proc.new{ |*args| 
				raise "Unresolved trait method conflict"
			}
		})
	end

	def solucionar_con(sym_mensaje, sym_estrategia)
		estrategias[sym_mensaje] = sym_estrategia
	end

	def self.define_strategy(sym_name, &bloque)
		name_strategy = "strategy_".concat(sym_name.to_s)
		define_method(name_strategy, (bloque))

		define_method(sym_name, Proc.new { |anotherTrait, &bloque2|
			sumar(anotherTrait, self.get_method(name_strategy), &bloque2)
		})
	end

	define_strategy(:con_todos) { |proc_1, proc_2|
		Proc.new { |*args|
			proc_1.call(args)
			proc_2.call(args)
		}
	}
	define_strategy(:foldeando) { |proc_1, proc_2, &bloque|
		Proc.new { |*args|
			bloque.call(proc_1.call(args), proc_2.call(args))
		}
	}
	define_strategy(:con_corte) { |proc_1, proc_2, &bloque|
		Proc.new { |*args|
			last_return = proc_1.call(args)
			(bloque.call(last_return)) ? last_return : proc_2.call(args)
		}
	}

end


class Class
	def uses(traitObj)
		traitObj.methodHash.each do |sym, bloque|
			self.send(:define_method, sym, &bloque)
		end
	end
end