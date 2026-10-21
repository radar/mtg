# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TranquilLandscape do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Plains"),
      Card("Island"),
      Card("Forest"),
      Card("Swamp"),
      Card("Mountain"),
    ]
  end

  let!(:landscape) { ResolvePermanent("Tranquil Landscape", owner: p1).tap(&:untap!) }

  it "taps for {C}" do
    p1.activate_ability(ability: landscape.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "sacrifices to fetch a basic Forest, Plains or Island tapped" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    choice = game.choices.last
    expect(choice.choices.map(&:name)).to contain_exactly("Plains", "Island", "Forest")
    forest = choice.choices.select { _1.name == "Forest" }.first
    game.resolve_choice!(targets: [forest])

    expect(p1.graveyard.by_name("Tranquil Landscape").count).to eq(1)
    expect(p1.permanents.by_name("Forest").count).to eq(1)
    expect(p1.permanents.by_name("Forest")).to all(be_tapped)
  end

  it "may fail to find" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    game.skip_choice!

    expect(p1.permanents.lands.count).to eq(0)
  end

  it "cycles for {G}{W}{U}" do
    card = Card("Tranquil Landscape", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(green: 1, white: 1, blue: 1)
    p1.cycle(card:) { _1.pay_mana(green: 1, white: 1, blue: 1) }
    game.settle!

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(8)
  end
end
