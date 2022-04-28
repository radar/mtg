require 'spec_helper'

RSpec.describe Magic::Cards::SeasonedHallowblade do
  include_context "two player game"

  subject { Card("Seasoned Hallowblade", controller: p1) }

  before do
    p1.draw!
    game.battlefield.add(subject)
  end

  context "activated ability" do
    def ability
      subject.activated_abilities.first
    end

    it "taps hallowblade, applies indestructible until eot" do
      expect(subject.activated_abilities.count).to eq(1)
      activation = p1.activate_ability(ability)
      activation.pay(:discard, p1.hand.cards.first)
      activation.activate!
      game.stack.resolve!
      expect(subject).to be_tapped
      expect(subject).to be_indestructible
      expect(subject.keyword_grants.count).to eq(1)
      expect(subject.keyword_grants.first.until_eot?).to eq(true)
    end
  end
end
