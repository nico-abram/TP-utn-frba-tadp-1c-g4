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
end