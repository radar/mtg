require "spec_helper"

RSpec.describe Magic::Cards::ObsessiveStitcher do
  include_context "two player game"

  subject(:permanent) { ResolvePermanent("Obsessive Stitcher") }

  it "taps to loot" do
    expect(p1).to receive(:draw!)

    ability = permanent.activated_abilities.first
    p1.activate_ability(ability: ability)

    choice = game.choices.first
    expect(choice).to be_a(Magic::Choice::Discard)
  end

  it "pays {2}{U}{B}, {T}, Sacrifice to return target creature card from graveyard" do
    p1.graveyard.add(Card("Wood Elves"))

    ability = permanent.activated_abilities.last
    p1.add_mana(blue: 2, black: 3)
    p1.activate_ability(ability: ability) do
      _1.pay_mana(generic: { black: 2 }, black: 1, blue: 1)
      _1.targeting(p1.graveyard.first)
    end

    expect(creatures.map(&:name)).to include("Wood Elves")
    expect(permanent.card.zone).to be_graveyard
  end
end
