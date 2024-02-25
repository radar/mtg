require 'spec_helper'

RSpec.describe Magic::Cards::KeenGlidemaster do
  include_context "two player game"
  subject { ResolvePermanent("Keen Glidemaster", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  context "activated ability" do
    it "gives wood elves flying" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(blue: 3)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1
          .pay_mana(generic: { blue: 2 }, blue: 1)
          .targeting(wood_elves)
      end

      game.tick!

      expect(wood_elves).to be_flying
      expect(wood_elves.keyword_grants.first.until_eot?).to eq(true)
    end
  end
end
