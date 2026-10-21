# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SeethingLandscape do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Island"),
      Card("Swamp"),
      Card("Mountain"),
      Card("Plains"),
      Card("Forest"),
    ]
  end

  let!(:landscape) { ResolvePermanent("Seething Landscape", owner: p1).tap(&:untap!) }

  it "taps for {C}" do
    p1.activate_ability(ability: landscape.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "sacrifices to fetch a basic Island, Swamp or Mountain tapped" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    choice = game.choices.last
    expect(choice.choices.map(&:name)).to contain_exactly("Island", "Swamp", "Mountain")
    mountain = choice.choices.select { _1.name == "Mountain" }.first
    game.resolve_choice!(targets: [mountain])

    expect(p1.graveyard.by_name("Seething Landscape").count).to eq(1)
    expect(p1.permanents.by_name("Mountain").count).to eq(1)
    expect(p1.permanents.by_name("Mountain")).to all(be_tapped)
  end

  it "may fail to find" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    game.skip_choice!

    expect(p1.permanents.lands.count).to eq(0)
  end

  it "cycles for {U}{B}{R}" do
    card = Card("Seething Landscape", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(blue: 1, black: 1, red: 1)
    p1.cycle(card:) { _1.pay_mana(blue: 1, black: 1, red: 1) }
    game.settle!

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(8)
  end
end
