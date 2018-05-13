
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
		# else exception?
		end
		nuevoTrait
	end
	
	def sumar(traitASumar, estrategia)
		nuevoTrait = Trait.create
		self.methodHash.each do |sym, proc|
			nuevoTrait.methodHash[sym] = proc
		end
		traitASumar.methodHash.each do |sym, proc|
			if nuevoTrait.methodHash.has_key? sym
				nuevoTrait.methodHash[sym] = estrategia.call(self.methodHash[sym], proc)
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

	def self.define_strategy(sym_name, &bloque)
		name_strategy = "def_strategy_".concat(sym_name.to_s)
		define_method(name_strategy, (bloque))

		define_method("strategy_".concat(sym_name.to_s), Proc.new { |anotherTrait|
			sumar(anotherTrait, self.get_method(name_strategy))
		})
	end

	def strategy_exec_all(anotherTrait)
		sumar(anotherTrait, Proc.new { |proc_1, proc_2|
			Proc.new { |*args|
				proc_1.call(args)
				proc_2.call(args)
			}
		})
	end

	def strategy_exec_with_fold(anotherTrait, &bloque)
		sumar(anotherTrait, Proc.new { |proc_1, proc_2|
			Proc.new { |*args|
				bloque.call(proc_1.call(args), proc_2.call(args))
			}
		})
	end

	def strategy_exec_with_stop(anotherTrait, &bloque_corte)
		sumar(anotherTrait, Proc.new { |proc_1, proc_2|
			Proc.new { |*args|
				last_return = proc_1.call(args)
				(bloque_corte.call(last_return)) ? last_return : proc_2.call(args)
			}
		})
	end

end


class Class
	def uses(traitObj)
		traitObj.methodHash.each do |sym, bloque|
			self.send(:define_method, sym, &bloque)
		end
	end
end