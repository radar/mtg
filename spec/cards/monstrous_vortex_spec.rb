# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MonstrousVortex do
  include_context "two player game"

  let!(:vortex) { ResolvePermanent("Monstrous Vortex", owner: p1) }
  let(:dreadmaw) { Card("Colossal Dreadmaw", owner: p1) }

  before do
    go_to_main_phase!
    p1.library.add(Card("Grizzly Bears", owner: p1))
    p1.library.add(Card("Forest", owner: p1))
    p1.hand.add(dreadmaw)
    p1.add_mana(green: 6)
  end

  def cast_dreadmaw
    p1.cast(card: dreadmaw) { |a| a.pay_mana(generic: { green: 4 }, green: 2) }
    game.settle!
  end

  it "discovers when a creature spell with power 5 or greater is cast" do
    cast_dreadmaw

    expect(game.choices.first).to be_a(Magic::Choice::Discover)
    expect(game.exile.cards.map(&:name)).to eq(["Grizzly Bears"])
  end

  it "puts the discovered card into hand when the cast is declined" do
    cast_dreadmaw
    game.skip_choice!

    expect(p1.hand.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "casts the discovered card for free" do
    cast_dreadmaw
    game.resolve_choice!
    game.stack.resolve!
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "puts exiled lands on the bottom of the library" do
    cast_dreadmaw
    game.skip_choice!

    expect(p1.library.cards.last.name).to eq("Forest")
  end

  it "ignores an opponent's big creature" do
    their_dreadmaw = Card("Colossal Dreadmaw", owner: p2)
    p2.hand.add(their_dreadmaw)
    go_to_main_phase_for!(p2)
    p2.add_mana(green: 6)
    p2.cast(card: their_dreadmaw) { |a| a.pay_mana(generic: { green: 4 }, green: 2) }
    game.settle!

    expect(game.choices).to be_empty
  end

  it "ignores small creatures" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(game.choices).to be_empty
  end
end
