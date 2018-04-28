
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

	def fold(proc1, proc2, &bloque)
		return Proc.new { |*args| 
		  bloque.call(proc1.call(args), proc2.call(args))
		}
	end

	def sumar(traitASumar, estrategia, &bloque)
		nuevoTrait = Trait.create
		self.methodHash.each do |sym, proc|
			nuevoTrait.methodHash[sym] = proc
		end
		traitASumar.methodHash.each do |sym, proc|
			if nuevoTrait.methodHash.has_key? sym
				nuevoTrait.methodHash[sym] = estrategia.call(self.methodHash[sym], proc, &bloque) 
			else
				nuevoTrait.methodHash[sym] = proc
			end
		end
		nuevoTrait
	end

	def +(traitASumar)
		sumar(traitASumar, Proc.new{ |*args| 
			Proc.new{ |*args| 
				raise "Unresolved trait method conflict"
			}
		})
	end

	def method_missing(mensaje, *args, &bloque)
		if mensaje.to_s.start_with? "sumar_con_"
			nombreEstrategia = mensaje.to_s[10..-1]
			if self.respond_to? nombreEstrategia
				#get_method es una alias de method
				#porque trait define method
				sumar(args[0], self.get_method(nombreEstrategia.to_sym), &bloque)
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

Trait.define do name :T1
	method :num do 1 end
end
Trait.define do name :T2
	method :num do 2 end
end
class C
	uses (T1.sumar_con_fold T2 do |a,b| a+b end)
end
puts C.new.num
#3
Trait.define do name :A; method :h do "hi" end end
puts (A << :h > :j) << :j > :k
	#<Trait:0x00000003b7b030
	# @methodHash={:h=>#<Proc:0x000000039e78e0@(pry):2>, :j=>#<Proc:0x000000039e78e0@(pry):2>, :k=>#<Proc:0x000000039e78e0@(pry):2>},
	# @methodToCreateAlias=nil>