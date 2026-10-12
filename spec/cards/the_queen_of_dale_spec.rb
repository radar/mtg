# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheQueenOfDale do
  include_context "two player game"

  let!(:queen) { ResolvePermanent("The Queen Of Dale", owner: p1) }

  before { go_to_main_phase_for!(p2) }

  def bolt_p1
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p1) }
    game.settle!
  end

  it "recruits when an opponent casts their first noncreature spell each turn" do
    library_before = p1.library.count
    bolt_p1

    expect(p1.library.count).to eq(library_before - 1)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end

  it "does not recruit for the second noncreature spell" do
    bolt_p1
    game.resolve_choice!(card: p1.hand.cards.first)
    game.stack.resolve!
    library_before = p1.library.count
    bolt_p1

    expect(p1.library.count).to eq(library_before)
  end

  it "ignores creature spells" do
    bears = Card("Grizzly Bears", owner: p2)
    p2.hand.add(bears)
    p2.add_mana(green: 2)
    library_before = p1.library.count
    p2.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p1.library.count).to eq(library_before)
  end

  it "ignores your own spells" do
    go_to_main_phase_for!(p1)
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    library_before = p1.library.count
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(p1.library.count).to eq(library_before)
  end
end
