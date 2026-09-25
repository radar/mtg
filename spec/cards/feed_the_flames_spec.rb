# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FeedTheFlames do
  include_context "two player game"

  let(:flames) { Card("Feed The Flames") }

  def cast_at(creature)
    p1.add_mana(red: 4)
    p1.cast(card: flames) do
      _1.pay_mana(generic: { red: 3 }, red: 1)
      _1.targeting(creature)
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals 5 damage to target creature" do
    giant = ResolvePermanent("Colossal Dreadmaw", owner: p2)
    cast_at(giant)
    expect(giant.damage).to eq(5)
  end

  it "exiles the creature instead if it dies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_at(bears)

    expect(game.battlefield.creatures).not_to include(bears)
    expect(p2.graveyard.cards.map(&:name)).not_to include("Grizzly Bears")
    expect(bears.card.zone).to be_exile
  end

  it "still exiles a creature that survives and dies later the same turn" do
    dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p2)
    cast_at(dreadmaw)
    dreadmaw.destroy!
    game.settle!

    expect(dreadmaw.card.zone).to be_exile
  end

  it "stops exiling once the turn is over" do
    dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p2)
    cast_at(dreadmaw)
    current_turn.end!
    current_turn.cleanup!
    dreadmaw.destroy!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Colossal Dreadmaw")
  end
end
