# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PineconeStrike do
  include_context "two player game"

  let(:strike) { Card("Pinecone Strike", owner: p1) }

  before do
    p1.hand.add(strike)
    p1.add_mana(red: 2)
  end

  def cast_with(*modes)
    p1.cast(card: strike) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      modes.each { |mode, target| action.choose_mode(mode) { _1.targeting(target) } }
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals 3 damage to a creature and exiles it if it dies" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_with([described_class::Damage, bear])

    expect(game.exile.cards).to include(bear.card)
    expect(p2.graveyard.cards).not_to include(bear.card)
  end

  it "leaves a creature that survives alone" do
    bear = ResolvePermanent("Ordinary Bear", owner: p2)
    cast_with([described_class::Damage, bear])

    expect(p2.creatures).to include(bear)
  end

  it "destroys an artifact token" do
    treasure = p2.game.then do
      Magic::Tokens::Treasure.new(game: game, owner: p2).resolve!
    end
    cast_with([described_class::DestroyToken, treasure])

    expect(p2.permanents).not_to include(treasure)
  end

  it "can do both" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    treasure = Magic::Tokens::Treasure.new(game: game, owner: p2).resolve!
    cast_with([described_class::Damage, bear], [described_class::DestroyToken, treasure])

    expect(game.exile.cards).to include(bear.card)
    expect(p2.permanents).not_to include(treasure)
  end

  it "can't target a nontoken artifact with the second mode" do
    ResolvePermanent("Sol Ring", owner: p2)
    expect(described_class::DestroyToken.new(game: game, card: strike).target_choices).to be_empty
  end
end
