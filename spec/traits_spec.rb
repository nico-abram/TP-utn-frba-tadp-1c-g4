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
		Trait.define do name :A; method :h do "hi" end end
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
	it "Estrategia de fold" do
		Trait.define do 
			name :T1
			method :num do |a,b| a+b end
		end
		Trait.define do name :T2
			method :num do |a,b| a-b end
		end
		class C
			uses (T1.sumar_con_fold T2 do |a,b| a+b end)
		end
		# 10+5+10-5 = 20
		expect(C.new.num 10, 5).to eq 20
	end
end