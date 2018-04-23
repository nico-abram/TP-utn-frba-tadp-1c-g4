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
			method :conflictMethod do 
				1
			end
			method :anotherMethod do 
				"Hi"
			end
		end
		Trait.define do
			name :B
			method :conflictMethod do 
				"Works"
			end
		end
		class SimpleTest
			uses B + (A - :conflictMethod)
		end
		expect(SimpleTest.new.conflictMethod).to eq "Works"
		expect(SimpleTest.new.anotherMethod).to eq "Hi"
	end
end