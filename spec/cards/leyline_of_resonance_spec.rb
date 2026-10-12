# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeylineOfResonance do
  include_context "two player game"

  def p1_library = [Card("Leyline Of Resonance", owner: p1), *13.times.map { Card("Forest", owner: p1) }]

  let(:strike) { Card("Sure Strike", owner: p1).tap { p1.hand.add(_1) } } # +3/+0 and first strike
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    game.resolve_choice!
    go_to_main_phase!
  end

  def cast_on(target)
    p1.add_mana(red: 2)
    p1.cast(card: strike) { _1.pay_mana(generic: { red: 1 }, red: 1).targeting(target) }
    game.settle!
  end

  it "copies an instant or sorcery that targets only a single creature you control" do
    cast_on(bears)
    game.skip_choice! # keep the original target
    game.stack.resolve!
    game.settle!

    expect(bears.power).to eq(8) # 2 + 3 + 3
  end

  it "may choose a new target for the copy" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_on(bears)
    game.resolve_choice!
    game.resolve_choice!(target: other)
    game.stack.resolve!
    game.settle!

    expect([bears.power, other.power]).to eq([5, 5])
  end

  it "doesn't copy a spell that targets an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(theirs)
    game.stack.resolve!
    game.settle!

    expect(theirs.power).to eq(5)
    expect(game.choices).to be_empty
  end

  it "doesn't copy a creature spell or a spell with no target" do
    bear_spell = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(green: 2)
    p1.cast(card: bear_spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(game.choices).to be_empty
  end
end
