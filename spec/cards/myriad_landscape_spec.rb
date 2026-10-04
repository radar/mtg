# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MyriadLandscape do
  include_context "two player game"

  def p1_library
    [
      *Array.new(7) { Card("Grizzly Bears") },
      Card("Forest"),
      Card("Forest"),
      Card("Swamp"),
      Card("Island"),
    ]
  end

  let!(:landscape) { ResolvePermanent("Myriad Landscape", owner: p1).tap(&:untap!) }

  def search!
    p1.add_mana(green: 2)
    p1.activate_ability(ability: landscape.activated_abilities.last) { _1.pay_mana(generic: { green: 2 }) }
    game.stack.resolve!
    game.choices.last
  end

  it "enters tapped" do
    expect(Card("Myriad Landscape", owner: p1).enters_tapped?).to be true
  end

  it "taps for {C}" do
    p1.activate_ability(ability: landscape.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "puts two basic lands that share a land type onto the battlefield tapped" do
    choice = search!
    forests = choice.choices.select { _1.name == "Forest" }
    game.resolve_choice!(targets: forests)

    expect(p1.graveyard.by_name("Myriad Landscape").count).to eq(1)
    expect(p1.permanents.by_name("Forest").count).to eq(2)
    expect(p1.permanents.by_name("Forest")).to all(be_tapped)
  end

  it "rejects two lands that don't share a land type" do
    choice = search!
    mixed = [choice.choices.find { _1.name == "Swamp" }, choice.choices.find { _1.name == "Island" }]

    expect { game.resolve_choice!(targets: mixed) }.to raise_error(ArgumentError, /share a land type/)
  end

  it "may find just one land" do
    choice = search!
    game.resolve_choice!(targets: [choice.choices.first])

    expect(p1.permanents.lands.count { _1.name != "Myriad Landscape" }).to eq(1)
  end
end
