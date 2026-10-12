# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VialSmasherTheFierce do
  include_context "two player game"

  let!(:smasher) { ResolvePermanent("Vial Smasher The Fierce", owner: p1) }

  before { go_to_main_phase! }

  def cast_bears!
    spell = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } # mana value 2
    p1.add_mana(green: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
  end

  it "deals damage equal to your first spell's mana value to a random opponent" do
    cast_bears!

    expect(p2.life).to eq(18)
  end

  it "can instead hit a planeswalker that opponent controls" do
    walker = ResolvePermanent("Garruk Unleashed", owner: p2)
    cast_bears!

    expect(game.choices.last.choices).to contain_exactly(p2, walker)
    game.resolve_choice!(target: walker)
    game.settle!

    expect(p2.life).to eq(20)
    expect(walker.loyalty).to be < 4
  end

  it "ignores a second spell the same turn" do
    cast_bears!
    game.stack.resolve!
    game.settle!
    cast_bears!

    expect(p2.life).to eq(18)
  end

  it "ignores the opponent's spells" do
    go_to_main_phase_for!(p2)
    spell = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(green: 2)
    p2.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect([p1.life, p2.life]).to eq([20, 20])
  end
end
