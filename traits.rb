
class Trait
    attr_accessor :methodHash
    def self.define(&bloque)
        a = Trait.new
        a.methodHash = Hash.new
        a.instance_eval(&bloque)
    end

    def name(sym)
        Object.const_set(sym, self)
    end

    # Agregar el metodo sym con el codigo bloque
    def method(sym, &bloque)
        puts methodHash
        puts sym
        puts bloque
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

Trait.define do
    name :A
    method :h do
        "H"
    end
end

class B uses A end
# B.new.h