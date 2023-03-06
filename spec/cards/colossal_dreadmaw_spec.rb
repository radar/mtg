require 'spec_helper'

RSpec.describe Magic::Cards::ColossalDreadmaw do
  include_context "two player game"

  subject! { ResolvePermanent("Colossal Dreadmaw", owner: p1) }

  context 'base card atrributes' do 
    it "is a dinosaur" do
      expect(subject.card.type_line).to eq("Creature -- Dinosaur")
    end
  
    it "Has trample" do
      expect(subject.trample?).to eq(true)
    end

    it "has an unmodified power + toughness" do
      expect(subject.power).to eq(6)
      expect(subject.toughness).to eq(6)
    end
  end 
 
end
