# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SelfReflection do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def bears_count = p1.creatures.select { _1.name == "Grizzly Bears" }.count

  it "creates a token that's a copy of target creature you control" do
    p1.add_mana(blue: 6)
    p1.cast(card: Card("Self-Reflection", owner: p1)) { |a| a.pay_mana(generic: { blue: 4 }, blue: 2).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(bears_count).to eq(2)
    expect(p1.creatures.count(&:token?)).to eq(1)
  end

  it "can be cast again from the graveyard with flashback for {3}{U}" do
    card = Card("Self-Reflection", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(blue: 4)
    p1.cast(card:, flashback: true) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(bears_count).to eq(2)
    expect(game.exile.cards).to include(card)
  end

  it "can't target an opponent's creature" do
    rival = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 6)

    expect { p1.cast(card: Card("Self-Reflection", owner: p1)) { |a| a.pay_mana(generic: { blue: 4 }, blue: 2).targeting(rival) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
