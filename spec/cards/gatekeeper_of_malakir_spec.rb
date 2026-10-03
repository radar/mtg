# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GatekeeperOfMalakir do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_gatekeeper(kicked:)
    p1.add_mana(black: 3)
    card = Card("Gatekeeper of Malakir", owner: p1)
    p1.cast(card: card) do |a|
      a.pay_mana(black: 2)
      a.pay_kicker(black: 1) if kicked
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 Vampire Warrior" do
    cast_gatekeeper(kicked: false)
    gatekeeper = p1.creatures.first

    expect([gatekeeper.power, gatekeeper.toughness]).to eq([2, 2])
  end

  it "does nothing when it was not kicked" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_gatekeeper(kicked: false)

    expect(game.choices).to be_empty
    expect(p2.creatures).to include(bears)
  end

  it "makes the target player sacrifice a creature of their choice when kicked" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_gatekeeper(kicked: true)
    game.resolve_choice!(target: p2)
    game.resolve_choice!(target: bears)
    game.settle!

    expect(p2.creatures).not_to include(bears)
    expect(p2.graveyard.cards).to include(bears.card)
  end

  it "lets the opponent choose which creature to sacrifice" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    elves = ResolvePermanent("Wood Elves", owner: p2)
    cast_gatekeeper(kicked: true)
    game.resolve_choice!(target: p2)
    game.resolve_choice!(target: elves)
    game.settle!

    expect(p2.creatures).to contain_exactly(bears)
    expect(p2.graveyard.cards).to include(elves.card)
  end
end
