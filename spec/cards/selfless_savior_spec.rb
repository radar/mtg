require 'spec_helper'

RSpec.describe Magic::Cards::SelflessSavior do
  include_context "two player game"

  subject { ResolvePermanent("Selfless Savior", owner: p1) }
  let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  context "activated ability" do
    def ability
      subject.activated_abilities.first
    end

    it "sacrifices selfless, applies indestructible to elves until eot" do
      p1.activate_ability(ability: ability) do
        _1.pay(:self_sacrifice, subject).targeting(wood_elves)
      end

      game.stack.resolve!
      game.tick!

      expect(wood_elves).to be_indestructible
      expect(wood_elves.keyword_grant_modifiers.first.until_eot?).to eq(true)
    end
  end
end
