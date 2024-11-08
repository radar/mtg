require 'spec_helper'

RSpec.describe Magic::Cards::BloodGlutton do
  include_context "two player game"

  subject! { ResolvePermanent("Blood Glutton", owner: p1) }

  context 'base card atrributes' do
    it "is a vampire" do
      expect(subject.card.types).to include("Creature")
      expect(subject.card.types).to include("Vampire")
    end

    it "Has lifelink" do
      expect(subject.lifelink?).to eq(true)
    end

    it "has an unmodified power + toughness" do
      expect(subject.power).to eq(4)
      expect(subject.toughness).to eq(3)
    end
  end

end
