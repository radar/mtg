# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StoneBySunlight do
  include_context "two player game"

  let(:stone) { Card("Stone By Sunlight", owner: p1) }

  before do
    p1.hand.add(stone)
    p1.add_mana(white: 2)
  end

  def cast_with(mode, target)
    p1.cast(card: stone) do |action|
      action.pay_mana(generic: { white: 1 }, white: 1)
      action.choose_mode(mode) { _1.targeting(target) }
    end
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "destroys a creature with power 4 or greater" do
    bear = ResolvePermanent("Ordinary Bear", owner: p2)
    cast_with(described_class::DestroyBig, bear)

    expect(bear.card.zone).to be_graveyard
  end

  it "can't destroy a creature with power 3 or less" do
    small = ResolvePermanent("Grizzly Bears", owner: p2)
    bear = ResolvePermanent("Ordinary Bear", owner: p2)

    choices = described_class::DestroyBig.new(game: game, card: stone).target_choices
    expect(choices).to eq([bear])
    expect(choices).not_to include(small)
  end

  it "makes a creature an indestructible artifact until end of turn" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with(described_class::BecomeArtifact, bear)

    expect(bear).to be_artifact
    expect(bear).to be_creature
    expect(bear).to be_indestructible
    bear.destroy!
    expect(p1.creatures).to include(bear)
  end

  it "wears off at end of turn" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_with(described_class::BecomeArtifact, bear)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bear).not_to be_artifact
    expect(bear).not_to be_indestructible
  end
end
