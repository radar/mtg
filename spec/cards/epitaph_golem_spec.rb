require "spec_helper"

RSpec.describe Magic::Cards::EpitaphGolem do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Epitaph Golem") }
  let!(:wood_elves) { Card("Wood Elves") }

  before do
    3.times { p1.library.add(Card("Island")) }
    p1.graveyard.add(wood_elves)
  end

  it "can move card from graveyard to library" do
    p1.add_mana(white: 2)
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.pay_mana(generic: { white: 2 })
      _1.targeting(wood_elves)
    end

    expect(wood_elves.zone).to be_library
    expect(p1.library.last).to eq(wood_elves)
  end
end
