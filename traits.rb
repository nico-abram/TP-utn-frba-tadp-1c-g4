
class Trait
	attr_accessor :methodHash
	attr_accessor :resoluciones
	attr_accessor :nombreYaUsado
	
	def self.define(&bloque)
		trait = Trait.create
		trait.instance_eval(&bloque)
		if trait.nombreYaUsado then
			usedTrait = Object.const_get(trait.nombreYaUsado)
			if usedTrait.is_a? Trait then
				usedTrait.instance_eval(&bloque)
			else
				raise "Const with trait name already exists"
			end
		end
	end

	def -(sym) #sym es el metodo a restar
		nuevoTrait = Trait.copy self
		nuevoTrait.methodHash.delete sym
		nuevoTrait
	end

	def <<(sym) #metodo al que crear alias
		nuevoTrait = Trait.copy self
		nuevoTrait.methodHash[sym.der] = methodHash[sym.izq]
		nuevoTrait
	end

	def +(traitASumar)
		estrategia = estrategia_default
		nuevoTrait = Trait.create
		self.methodHash.each do |sym, proc|
			nuevoTrait.methodHash[sym] = proc
		end
		traitASumar.methodHash.each do |sym, proc|
			if nuevoTrait.methodHash.has_key? sym
				estrategiaAUsar = estrategia
				estrategiaAUsar = resoluciones[sym] if resoluciones[sym]
				estrategiaAUsar = traitASumar.resoluciones[sym] if traitASumar.resoluciones[sym]
				nuevoTrait.methodHash[sym] = estrategiaAUsar.call(self.methodHash[sym], proc)
			else
				nuevoTrait.methodHash[sym] = proc
			end
		end
		nuevoTrait
	end

	def estrategia_default
		Proc.new{ |proc_1, proc_2|
			Proc.new{ |*args| 
				raise "Unresolved trait method conflict"
			}
		}
	end

	def solucionar_con(sym_mensaje, estrategia = nil, &bloque)
		nuevoTrait = Trait.copy self
		if estrategia.respond_to?(:call)
			nuevoTrait.resoluciones[sym_mensaje] = estrategia
		else
			nuevoTrait.resoluciones[sym_mensaje] = bloque
		end
		nuevoTrait
	end

	def self.define_strategy(sym_nombre, proc_estrategia = nil, &bloque_estrategia)
		proc_estrategia = bloque_estrategia if bloque_estrategia
		define_method(sym_nombre, Proc.new { |mensaje|
			solucionar_con(mensaje, proc_estrategia)
		})
	end

	def self.define_dependant_strategy(sym_nombre, proc_estrategia = nil, &bloque_estrategia)
		proc_estrategia = bloque_estrategia unless proc_estrategia
		define_method(sym_nombre, Proc.new { |mensaje, &bloque|
			solucionar_con(mensaje, proc_estrategia.call(bloque))
		})
	end

	define_strategy(:con_todos) { |proc_1, proc_2|
		Proc.new { |*args|
			proc_1.call(args)
			proc_2.call(args)
		}
	}
	define_dependant_strategy(:foldeando) { |bloque|
		Proc.new { |proc_1, proc_2|
			Proc.new { |*args|
				bloque.call(proc_1.call(args), proc_2.call(args))
			}
		}
	}
	define_dependant_strategy(:con_corte) { |bloque_de_corte|
		Proc.new { |proc_1, proc_2|
			Proc.new { |*args|
				last_return = proc_1.call(args)
				(bloque_de_corte.call(last_return)) ? last_return : proc_2.call(args)
			}
		}
	}
	define_strategy(:izq) { |proc_1, proc_2|
		Proc.new { |*args|
			proc_1.call(args)
		}
	}
	define_strategy(:der) { |proc_1, proc_2|
		Proc.new { |*args|
			proc_2.call(args)
		}
	}

	private

	def self.copy(trait)
		copiedTrait = Trait.new
		copiedTrait.methodHash = trait.methodHash.clone
		copiedTrait.resoluciones = trait.resoluciones.clone
		copiedTrait
	end

	def self.create()
		trait = Trait.new
		trait.methodHash = Hash.new
		trait.resoluciones = Hash.new
		trait
	end

	def name(sym)
		if Object.const_defined?(sym) then
			self.nombreYaUsado = sym
		else
			Object.const_set(sym, self)
		end
	end

	alias_method :get_method, :method
	# Agregar el metodo sym con el codigo bloque
	def method(sym, &bloque)
		methodHash[sym] = bloque
	end

end

class Class
	def uses(traitObj)
		traitObj.methodHash.each do |sym, bloque|
			self.send(:define_method, sym, &bloque)
		end
	end
end

class Symbol
	def >>(s2)
		Struct.new(:izq, :der).new(self, s2)
	end
end