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
      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: subject, ability: subject.activated_abilities.first)
        .pay(p1, :discard, p1.hand.cards.first)
      game.take_action(action)
      expect(subject).to be_tapped
      expect(subject).to be_indestructible
      expect(subject.keyword_grants.count).to eq(1)
      expect(subject.keyword_grants.first.until_eot?).to eq(true)
    end
  end
end
