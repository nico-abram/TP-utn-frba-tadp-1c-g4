require_relative "../traits"

describe Trait do
	it "Should use the trait method" do
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
	it "Should not have conflicts" do
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
	it "Should have a conflict" do
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
  it "Should work with aliases" do
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
    expect{SimpleTest.new.hello}to eq "hi"
  end
end