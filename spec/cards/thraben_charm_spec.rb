# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrabenCharm do
  include_context "two player game"

  let!(:charm) { Card("Thraben Charm", owner: p1).tap { p1.hand.add(_1) } }

  def cast_charm(mode, *targets)
    p1.add_mana(white: 1, colorless: 1)
    p1.cast(card: charm) do |action|
      action.pay_mana(white: 1, generic: { colorless: 1 })
      action.choose_mode(mode) { _1.targeting(*targets) }
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals damage equal to twice the creatures you control" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    target = ResolvePermanent("Serra Angel", owner: p2)

    cast_charm(described_class::DamageCreature, target)

    expect(p2.graveyard.cards.map(&:name)).to eq(["Serra Angel"])
  end

  it "destroys an enchantment" do
    enchantment = ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    cast_charm(described_class::DestroyEnchantment, enchantment)

    expect(p2.graveyard.cards.map(&:name)).to eq(["Sanctum of Calm Waters"])
  end

  it "exiles a player's graveyard" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))

    cast_charm(described_class::ExileGraveyard, p2)

    expect(p2.graveyard.cards).to be_empty
  end

  it "exiles any number of players' graveyards" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))

    cast_charm(described_class::ExileGraveyard, p1, p2)

    # The charm itself reaches p1's graveyard only after its graveyard was exiled.
    expect(p1.graveyard.cards.map(&:name)).to eq(["Thraben Charm"])
    expect(p2.graveyard.cards).to be_empty
  end

  it "exiles only the targeted players' graveyards" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))

    cast_charm(described_class::ExileGraveyard, p2)

    expect(p1.graveyard.cards.map(&:name)).to match_array(["Grizzly Bears", "Thraben Charm"])
    expect(p2.graveyard.cards).to be_empty
  end

  it "can be cast with no graveyards targeted" do
    p2.graveyard.add(Card("Grizzly Bears", owner: p2))

    cast_charm(described_class::ExileGraveyard)

    expect(p2.graveyard.cards.count).to eq(1)
  end
end
