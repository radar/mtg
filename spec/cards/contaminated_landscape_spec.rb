# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ContaminatedLandscape do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Plains"),
      Card("Island"),
      Card("Swamp"),
      Card("Mountain"),
      Card("Forest"),
    ]
  end

  let!(:landscape) { ResolvePermanent("Contaminated Landscape", owner: p1).tap(&:untap!) }

  it "taps for {C}" do
    p1.activate_ability(ability: landscape.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "sacrifices to fetch a basic Plains, Island or Swamp tapped" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    choice = game.choices.last
    expect(choice.choices.map(&:name)).to contain_exactly("Plains", "Island", "Swamp")
    swamp = choice.choices.select { _1.name == "Swamp" }.first
    game.resolve_choice!(targets: [swamp])

    expect(p1.graveyard.by_name("Contaminated Landscape").count).to eq(1)
    expect(p1.permanents.by_name("Swamp").count).to eq(1)
    expect(p1.permanents.by_name("Swamp")).to all(be_tapped)
  end

  it "may fail to find" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    game.skip_choice!

    expect(p1.permanents.lands.count).to eq(0)
  end

  it "cycles for {W}{U}{B}" do
    card = Card("Contaminated Landscape", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(white: 1, blue: 1, black: 1)
    p1.cycle(card:) { _1.pay_mana(white: 1, blue: 1, black: 1) }
    game.settle!

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(8)
  end
end
