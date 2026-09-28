# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReapingWillow do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:willow) { ResolvePermanent("Reaping Willow", owner: p1) }

  it "is a 3/6 lifelink treefolk cleric that enters with two -1/-1 counters" do
    expect(willow.card.types).to include("Treefolk", "Cleric")
    expect(willow.power).to eq(1)
    expect(willow.toughness).to eq(4)
    expect(willow.lifelink?).to be(true)
  end

  it "returns target creature card with mana value 3 or less from the graveyard to the battlefield" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    p1.add_mana(black: 2)

    p1.activate_ability(ability: willow.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.zone).to be_battlefield
    expect(willow.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
  end

  it "cannot target a creature card with mana value 4 or more" do
    expensive_creature = Card("Sun-Dappled Celebrant", owner: p1)
    p1.graveyard.add(expensive_creature)
    p1.add_mana(black: 2)

    expect { p1.activate_ability(ability: willow.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(expensive_creature) } }
      .to raise_error(/Invalid target/)
  end
end
