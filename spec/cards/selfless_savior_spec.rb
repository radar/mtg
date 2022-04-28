require 'spec_helper'

RSpec.describe Magic::Cards::SelflessSavior do
  include_context "two player game"

  subject { Card("Selfless Savior", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p1) }

  before do
    p1.draw!
    game.battlefield.add(wood_elves)
    game.battlefield.add(subject)
  end

  context "activated ability" do
    def ability
      subject.activated_abilities.first
    end

    it "sacrifices selfless, applies indestructible to elves until eot" do
      expect(subject.activated_abilities.count).to eq(1)
      activation = p1.activate_ability(ability).targeting(wood_elves)
      activation.pay(:sacrifice, subject)
      activation.activate!
      game.stack.resolve!
      expect(wood_elves).to be_indestructible
      expect(wood_elves.keyword_grants.first.until_eot?).to eq(true)
    end
  end
end
