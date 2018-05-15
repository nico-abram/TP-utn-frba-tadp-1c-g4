require_relative "../traits"

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
		Trait.define do
			name :A
			method :conflictingMethod do 
				1
			end
			method :anotherMethod do 
				"Hi"
			end
		end
		Trait.define do
			name :B
			method :conflictingMethod do 
				"Works"
			end
		end
		class SimpleTest
			uses B + (A - :conflictingMethod)
		end
		expect(SimpleTest.new.conflictingMethod).to eq "Works"
		expect(SimpleTest.new.anotherMethod).to eq "Hi"
	end

  	it "Uso alias simple" do
		Trait.define do
			name :A
			method :metodo1 do
				"hi"
			end
			method :metodo2 do
				"bye"
			end
		end
		class SimpleTest
			uses A << :metodo1 > :hello
		end
		expect(SimpleTest.new.hello).to eq "hi"
	end

	it "Multiples Alias" do
		Trait.define do
			name :A
			method :h do
				"hi"
			end
		end
		puts 
		Trait.define do
			name :A
			method :metodo1 do
				"hi"
			end
		end
		class SimpleTest
			uses (A << :metodo1 > :metodo2) << :metodo2 > :metodo3
		end
		expect(SimpleTest.new.metodo3).to eq "hi"
	end
	
	it "Excepcion cuando hay un conflicto" do
		Trait.define do
			name :A
			method :conflictingMethod do 
				1
			end
		end
		Trait.define do
			name :B
			method :conflictingMethod do 
				"Works"
			end
		end
		class SimpleTest
			uses A + B
		end
		expect{SimpleTest.new.conflictingMethod}.to raise_error "Unresolved trait method conflict"
	end

	it "Estrategia de ejecutar todos los métodos" do
		miValor = 2

		Trait.define do
			name :T1
			method :random_operation do
				miValor += 2
			end
		end
		Trait.define do
			name :T2
			method :random_operation do
				miValor *= 2
			end
		end

		class SimpleTest
			uses (T1.con_todos T2)
		end

		miTest = SimpleTest.new
		miTest.random_operation()
				
		expect(miValor).to eq 8
	end

	it "Estrategia de ejecutar con fold" do
		Trait.define do
			name :T1
			method :random_operation do
				7
			end
		end
		Trait.define do
			name :T2
			method :random_operation do
				3
			end
		end

		class SimpleTest
			uses (T1.foldeando T2 do |res_1, res_2|
					res_1 + res_2
				end)
		end

		miTest = SimpleTest.new
				
		expect(miTest.random_operation()).to eq 10
	end

	it "Estrategia de condición de corte" do
		Trait.define do
			name :T1
			method :random_operation do
				7
			end
		end
		Trait.define do
			name :T2
			method :random_operation do
				8
			end
		end

		class SimpleTest
			uses (T1.con_corte T2 do |res|
					res.odd?
				end)
		end

		miTest = SimpleTest.new
				
		expect(miTest.random_operation()).to eq 7
	end

	it "Definir propia estrategia (ejecutar segundo método)" do
		Trait.define do
			name :T1
			method :getSomeNum do
				6
			end
		end
		Trait.define do
			name :T2
			method :getSomeNum do
				4
			end
		end
		
		Trait.define_strategy :exec_second do |p1, p2|
			Proc.new { |*args|
				p2.call(args)
			}
		end

		class SimpleTest
			uses T1.exec_second T2
		end

		miTest = SimpleTest.new

		expect(miTest.getSomeNum).to eq 4
	end
	  
	it "Estrategia por metodo" do
		Trait.define do
			name :T1
			method :getSomeNum do
				6
			end
			method :getAnotherNum do
				5
			end
		end
		Trait.define do
			name :T2
			method :getSomeNum do
				4
			end
			method :getAnotherNum do
				3
			end
		end
		
		Trait.define_strategy :exec_second do |p1, p2|
			Proc.new { |*args|
				p2.call(args)
			}
		end

		class SimpleTest
			uses T1.solucionar_con(:getSomeNum, :estrategia_izq) + T2
		end

		miTest = SimpleTest.new

		expect(miTest.getSomeNum).to eq 6
		expect{SimpleTest.new.getAnotherNum}.to raise_error "Unresolved trait method conflict"
	end
end