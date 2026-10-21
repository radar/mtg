# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShelteringLandscape do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Mountain"),
      Card("Forest"),
      Card("Plains"),
      Card("Island"),
      Card("Swamp"),
    ]
  end

  let!(:landscape) { ResolvePermanent("Sheltering Landscape", owner: p1).tap(&:untap!) }

  it "taps for {C}" do
    p1.activate_ability(ability: landscape.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "sacrifices to fetch a basic Mountain, Forest or Plains tapped" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    choice = game.choices.last
    expect(choice.choices.map(&:name)).to contain_exactly("Mountain", "Forest", "Plains")
    plains = choice.choices.select { _1.name == "Plains" }.first
    game.resolve_choice!(targets: [plains])

    expect(p1.graveyard.by_name("Sheltering Landscape").count).to eq(1)
    expect(p1.permanents.by_name("Plains").count).to eq(1)
    expect(p1.permanents.by_name("Plains")).to all(be_tapped)
  end

  it "may fail to find" do
    p1.activate_ability(ability: landscape.activated_abilities.last)
    game.stack.resolve!
    game.skip_choice!

    expect(p1.permanents.lands.count).to eq(0)
  end

  it "cycles for {R}{G}{W}" do
    card = Card("Sheltering Landscape", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(red: 1, green: 1, white: 1)
    p1.cycle(card:) { _1.pay_mana(red: 1, green: 1, white: 1) }
    game.settle!

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(8)
  end
end
