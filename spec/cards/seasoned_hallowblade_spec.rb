require 'spec_helper'

RSpec.describe Magic::Cards::SeasonedHallowblade do
  include_context "two player game"

  subject { ResolvePermanent("Seasoned Hallowblade", owner: p1) }

  before do
    p1.draw!
  end

  context "activated ability" do
    it "taps hallowblade, applies indestructible until eot" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1.pay(:discard, p1.hand.cards.first)
      end

      game.tick!
      expect(subject).to be_tapped
      expect(subject).to be_indestructible
      expect(subject.keyword_grants.count).to eq(1)
      expect(subject.keyword_grants.first.until_eot?).to eq(true)
    end
  end
end
