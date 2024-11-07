require "spec_helper"

RSpec.describe Magic::Cards::CrownOfSkemfar do
  include_context "two player game"

  subject(:crown_of_skemfar) { Card("Crown Of Skemfar") }

  let!(:wood_elves) { ResolvePermanent("Wood Elves") }

  it "attaches to a creature" do
    p1.add_mana(green: 4)
    action = cast_action(player: p1, card: subject)
      .pay_mana(green: 2, generic: { green: 2 })
      .targeting(wood_elves)
    game.take_action(action)
    game.tick!

    aggregate_failures do
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
      expect(wood_elves.has_keyword?(Magic::Cards::Keywords::REACH)).to eq(true)
    end

    expect(p1.permanents.by_name("Crown of Skemfar").count).to eq(1)
  end

  context "return from graveyard to hand" do
    let(:crown_of_skemfar) { Card("Crown Of Skemfar") }

    before do
      p1.graveyard.add(crown_of_skemfar)
    end

    it "returns to hand" do
      ability = crown_of_skemfar.activated_abilities.first
      p1.add_mana(green: 3)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { green: 2 }, green: 1)
      end

      game.tick!

      expect(p1.hand).to include(crown_of_skemfar)
    end
  end
end
