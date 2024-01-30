require 'spec_helper'

RSpec.describe Magic::Cards::Shacklegeist do
  include_context "two player game"
  let(:roaming_ghostlight) { ResolvePermanent("Roaming Ghostlight", owner: p2) }
  let(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  subject(:shacklegeist) { ResolvePermanent("Shacklegeist") }

  it "can only block creatures with flying" do
    expect(shacklegeist.can_block?(roaming_ghostlight)).to eq(true)
    expect(shacklegeist.can_block?(wood_elves)).to eq(false)
  end

  context "taps two untapped spirits, to tap another creature" do
    before do
      ResolvePermanent("Ageless Guardian", owner: p1)
    end

    it "taps the creature" do
      other_spirit = p1.creatures.by_name("Ageless Guardian").first

      p1.activate_ability(ability: shacklegeist.activated_abilities.first) do
        _1.pay_multi_tap([shacklegeist, other_spirit])
        _1.targeting(wood_elves)
      end

      game.tick!

      expect(wood_elves).to be_tapped
    end
  end
end
