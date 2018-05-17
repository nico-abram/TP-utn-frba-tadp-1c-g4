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
			uses A << (:metodo1 >> :hello)
		end
		expect(SimpleTest.new.hello).to eq "hi"
	end

	it "Multiples Alias" do
		helperGeneric2(:metodo1 , "hi", nil, :metodo2, "bye", nil, :A, :Nada)
		class SimpleTest
			uses (A << (:metodo1 >> :metodo2)) << (:metodo2 >> :metodo3)
		end
		expect(SimpleTest.new.metodo3).to eq "hi"
	end
	
	it "Excepcion cuando hay un conflicto" do
		helperGeneric(:conflictingMethod, 1, "Worls", :A, :B)
		class SimpleTest
			uses A + B
		end
		expect{SimpleTest.new.conflictingMethod}.to raise_error "Unresolved trait method conflict"
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
			uses (T1.con_todos :random_operation) +  T2
		end
		expect(SimpleTest.new.random_operation()).to eq 8
	end

	it "Estrategia de ejecutar con fold" do
		helperGeneric(:random_operation, 7, 3)
		class SimpleTest
			uses T1.foldeando(:random_operation) { |res_1, res_2|
					res_1 + res_2
				} + T2
		end
		expect(SimpleTest.new.random_operation()).to eq 10
	end

	it "Estrategia de condición de corte" do
		helperGeneric(:random_operation, 7, 8)
		class SimpleTest
			uses (T1.con_corte(:random_operation) do |res|
					res.odd?
				end) + T2
		end
		expect(SimpleTest.new.random_operation()).to eq 7
	end

	it "Definir propia estrategia (ejecutar segundo método)" do
		helperGeneric(:getSomeNum, 6, 4)
		class SimpleTest
			exec_second = Proc.new { |p1, p2|
				Proc.new { |*args|
					p2.call(args)
				}
			}
			uses T1.solucionar_con(:getSomeNum, exec_second) + T2
		end
		expect(SimpleTest.new.getSomeNum).to eq 4
		class SimpleTest2
			exec_fst = Proc.new { |p1, p2|
				Proc.new { |*args|
					p1.call(args)
				}
			}
			uses T1.solucionar_con(:getSomeNum, exec_fst) + T2
		end
		expect(SimpleTest2.new.getSomeNum).to eq 6
	end
	  
	it "Estrategia por metodo" do
		helperGeneric2(:getSomeNum, 6, 4, :getAnotherNum, 5, 3)
		class SimpleTest
			izquierda = Proc.new { |proc_1, proc_2|
				Proc.new { |*args|
					proc_1.call(args)
				}
			}
			uses T1.solucionar_con(:getSomeNum, izquierda) + T2
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
	end

	it "'Open Traits'" do
		helperGeneric(:getSomeNum, 6, 4, :A, :B)
		helperGeneric(:getAnotherNum, 5, 3, :A, :B)

		class SimpleTest
			uses A
		end
		class SimpleTest2
			uses B
		end
		expect(SimpleTest.new.getSomeNum).to eq 6
		expect(SimpleTest.new.getAnotherNum).to eq 5
		expect(SimpleTest2.new.getSomeNum).to eq 4
		expect(SimpleTest2.new.getAnotherNum).to eq 3
	end
end