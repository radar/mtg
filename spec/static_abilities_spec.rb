require 'spec_helper'

RSpec.describe Magic::StaticAbilities do
  let(:card) { double(Magic::Card) }
  let(:ability) { double(Magic::Abilities::Static::PowerAndToughnessModification, applies_to?: true, conditions_met?: true) }
  subject { Magic::StaticAbilities.new([ability]) }

  context "applies_to" do
    it "finds the abilities that apply to the card" do
      expect(subject.applies_to(card)).to include(ability)
    end
  end
end
