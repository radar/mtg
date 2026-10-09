# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UncoverTheMoonLetters do
  include_context "two player game"

  before do
    go_to_main_phase!
    ResolvePermanent("Uncover The Moon-Letters", owner: p1)
  end

  def cast_bolt
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!
  end

  it "draws cards equal to mana spent on a noncreature spell, then discards two" do
    library_before = p1.library.count
    cast_bolt
    game.resolve_choice!

    expect(p1.library.count).to eq(library_before - 1)
    expect(game.choices.count { _1.is_a?(Magic::Choice::Discard) }).to eq(2)
  end

  it "does nothing when the draw is declined" do
    cast_bolt
    game.skip_choice!

    expect(game.choices.select { _1.is_a?(Magic::Choice::Discard) }).to be_empty
  end

  it "ignores creature spells" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.add_mana(green: 2)

    p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

    expect(game.choices).to be_empty
  end
end
