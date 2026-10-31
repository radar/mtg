# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StoneOfErech do
  include_context "two player game"

  let!(:stone) { ResolvePermanent("Stone Of Erech", owner: p1) }

  def activate(target, mana: { red: 2 })
    p1.add_mana(**mana)
    p1.activate_ability(ability: stone.activated_abilities.first) do |a|
      a.pay_mana(generic: { red: 2 })
      a.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary artifact" do
    expect(stone).to be_legendary
    expect(stone).to be_artifact
  end

  it "exiles a creature an opponent controls instead of letting it die" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.destroy!
    game.settle!

    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    expect(p2.graveyard.cards.map(&:name)).not_to include("Grizzly Bears")
  end

  it "lets your own creatures die normally" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.destroy!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(game.exile.cards.map(&:name)).not_to include("Grizzly Bears")
  end

  it "doesn't affect noncreature permanents an opponent controls going to the graveyard" do
    map = ResolvePermanent("Expedition Map", owner: p2)
    map.destroy!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Expedition Map")
  end

  it "exiles target player's graveyard, sacrifices itself and draws a card" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))
    p2.graveyard.add(Card("Serra Angel", owner: p2))
    hand = p1.hand.count
    activate(p2)

    expect(p2.graveyard.cards).to be_empty
    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears", "Serra Angel")
    expect(stone.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "can target your own graveyard and leaves the opponent's alone" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    p2.graveyard.add(Card("Serra Angel", owner: p2))
    activate(p1)

    expect(p1.graveyard.cards).to be_empty
    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    expect(p2.graveyard.cards.map(&:name)).to eq(["Serra Angel"])
  end

  it "needs {2} to activate" do
    expect { activate(p2, mana: { red: 1 }) }.to raise_error(StandardError)
    expect(p1.permanents).to include(stone)
  end
end
