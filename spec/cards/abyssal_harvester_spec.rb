# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbyssalHarvester do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:harvester) { ResolvePermanent("Abyssal Harvester", owner: p1) }

  def activate(target)
    p1.activate_ability(ability: harvester.activated_abilities.first) { _1.targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def nightmare_tokens = p1.permanents.select { _1.token? && _1.type?("Nightmare") }

  it "is a 3/2 Demon Warlock" do
    expect([harvester.power, harvester.toughness]).to eq([3, 2])
  end

  it "exiles a creature card put into a graveyard this turn and makes a Nightmare token copy of it" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    card = p2.graveyard.cards.find { _1.name == "Grizzly Bears" }
    activate(card)

    expect(game.exile.cards).to include(card)
    expect(p2.graveyard.cards).not_to include(card)
    copy = nightmare_tokens.first
    expect(copy.name).to eq("Grizzly Bears")
    expect([copy.power, copy.toughness]).to eq([2, 2])
    expect(copy.type?("Bear")).to eq(true)
    expect(copy.controller).to eq(p1)
    expect(harvester).to be_tapped
  end

  it "can take your own creature card, too" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    activate(p1.graveyard.cards.find { _1.name == "Grizzly Bears" })

    expect(nightmare_tokens.size).to eq(1)
  end

  it "exiles the other Nightmare tokens you control when it makes another" do
    2.times do
      harvester.untap!
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      activate(p2.graveyard.cards.find { _1.name == "Grizzly Bears" })
    end

    expect(nightmare_tokens.size).to eq(1)
  end

  it "can't target a creature card that was put into the graveyard on an earlier turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    old = p2.graveyard.cards.find { _1.name == "Grizzly Bears" }
    game.next_turn

    expect { activate(old) }.to raise_error(/Invalid target/)
    expect(nightmare_tokens).to be_empty
  end

  it "can't target a noncreature card" do
    ResolvePermanent("Island", owner: p2).destroy!
    game.settle!
    land = p2.graveyard.cards.find { _1.name == "Island" }
    expect { activate(land) }.to raise_error(/Invalid target/)
  end
end
