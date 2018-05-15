require_relative "../traits"

def helperGeneric2(mensaje1, value1, value2, mensaje2, value3, value4, t1 = :T1, t2 = :T2)
	Trait.define do name t1
		method mensaje1 do
			value1
		end
		method mensaje2 do
			value3
		end
	end
	Trait.define do name t2
		method mensaje1 do
			value2
		end
		if value4 then
			method mensaje2 do
				value4
			end
		end
	end
end
def helperGeneric(mensaje, value1, value2, t1 = :T1, t2 = :T2)
	helperGeneric2(mensaje, value1, value2, :nada, 0, 1, t1, t2)
end
describe Trait do
	it "Uso normal y simple de un trait" do
		Trait.define do
			name :SimpleTrait
			method :testMethod do 
				"Works"
			end
		end
		class SimpleTest
			uses SimpleTrait
		end
		expect(SimpleTest.new.testMethod).to eq "Works"
	end

	it "Restar un metodo a un trait" do
		helperGeneric2(:conflictingMethod, 1, "Works", :anotherMethod, "Hi", nil, :A, :B)
		class SimpleTest
			uses B + (A - :conflictingMethod)
		end
		expect(SimpleTest.new.conflictingMethod).to eq "Works"
		expect(SimpleTest.new.anotherMethod).to eq "Hi"
	end

  	it "Uso alias simple" do
		helperGeneric2(:metodo1 , "hi", nil, :metodo2, "bye", nil, :A, :Nada)
		class SimpleTest
			uses A << :metodo1 > :hello
		end
		expect(SimpleTest.new.hello).to eq "hi"
	end

	it "Uso alias simple con sintaxis alternative" do
		helperGeneric2(:metodo1 , "hi", nil, :metodo2, "bye", nil, :A, :Nada)
		class SimpleTest
			uses A << (:metodo1 >> :hello)
		end
		expect(SimpleTest.new.hello).to eq "hi"
	end

	it "Multiples Alias" do
		helperGeneric2(:metodo1 , "hi", nil, :metodo2, "bye", nil, :A, :Nada)
		class SimpleTest
			uses (A << :metodo1 > :metodo2) << :metodo2 > :metodo3
		end
		expect(SimpleTest.new.metodo3).to eq "hi"
	end

	it "Multiples Alias con sintaxis alternativa" do
		helperGeneric2(:metodo1 , "hi", nil, :metodo2, "bye", nil, :A, :Nada)
		class SimpleTest
			uses (A << (:metodo1 > :metodo2)) << (:metodo2 > :metodo3)
		end
		expect(SimpleTest.new.metodo3).to eq "hi"
	end
	
	it "Excepcion cuando hay un conflicto" do
		helperGeneric(:conflictingMethod, 1, "Worls", :A, :B)
		class SimpleTest
			uses A + B
		end
		expect{SimpleTest.new.conflictingMethod}.to raise_error "Unresolved trait method conflict"
		class SimpleTestMensaje
			uses A.sumar B
		end
		expect{SimpleTestMensaje.new.conflictingMethod}.to raise_error "Unresolved trait method conflict"
	end

	it "Estrategia de ejecutar todos los métodos" do
		miValor = 2
		Trait.define do name :T1
			method :random_operation do
				miValor += 2
			end
		end
		Trait.define do name :T2
			method :random_operation do
				miValor *= 2
			end
		end
		class SimpleTest
			uses (T1.con_todos T2)
		end
		expect(SimpleTest.new.random_operation()).to eq 8
	end

	it "Estrategia de ejecutar con fold" do
		helperGeneric(:random_operation, 7, 3)
		class SimpleTest
			uses (T1.foldeando T2 do |res_1, res_2|
					res_1 + res_2
				end)
		end
		expect(SimpleTest.new.random_operation()).to eq 10
	end

	it "Estrategia de condición de corte" do
		helperGeneric(:random_operation, 7, 8)
		class SimpleTest
			uses (T1.con_corte T2 do |res|
					res.odd?
				end)
		end
		expect(SimpleTest.new.random_operation()).to eq 7
	end

	it "Definir propia estrategia (ejecutar segundo método)" do
		helperGeneric(:getSomeNum, 6, 4)
		Trait.define_strategy :exec_second do |p1, p2|
			Proc.new { |*args|
				p2.call(args)
			}
		end
		Trait.define_strategy :exec_fst , Proc.new { |p1, p2|
				Proc.new { |*args|
					p1.call(args)
				}
			}
		class SimpleTest
			uses T1.exec_second T2
		end
		expect(SimpleTest.new.getSomeNum).to eq 4
		class SimpleTest2
			uses T1.exec_fst T2
		end
		expect(SimpleTest2.new.getSomeNum).to eq 6
	end
	  
	it "Estrategia por metodo" do
		helperGeneric2(:getSomeNum, 6, 4, :getAnotherNum, 5, 3)
		class SimpleTest
			uses T1.solucionar_con(:getSomeNum, :estrategia_izq) + T2
		end
		expect(SimpleTest.new.getSomeNum).to eq 6
		expect{SimpleTest.new.getAnotherNum}.to raise_error "Unresolved trait method conflict"
	end

	it "Estrategias definidas en el momento" do
		helperGeneric2(:getSomeNum, 6, 4, :getAnotherNum, 5, 3)
		class SimpleTest
			uses T1.solucionar_con(:getSomeNum, Proc.new {|a, b| Proc.new { |*args| b.call(args)}}).
				solucionar_con(:getAnotherNum) {|a, b| Proc.new { |*args| a.call(args)}}  + T2
		end
		expect(SimpleTest.new.getSomeNum).to eq 4 #mediante proc
		expect(SimpleTest.new.getAnotherNum).to eq 5 #mediante bloque
		class TestSuma
			uses T1.sumar(T2) {|a, b| Proc.new { |*args| a.call(args)}}
		end
		expect(TestSuma.new.getAnotherNum).to eq 5
		expect(TestSuma.new.getSomeNum).to eq 6
		class TestSuma2
			uses T1.sumar(T2, Proc.new {|a, b| Proc.new { |*args| a.call(args)}})
		end
		expect(TestSuma2.new.getAnotherNum).to eq 5
		expect(TestSuma2.new.getSomeNum).to eq 6
	end
end