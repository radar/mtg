# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NightmareSower do
  include_context "two player game"

  let!(:sower) { ResolvePermanent("Nightmare Sower", owner: p1) }

  it "is a 2/3 flying lifelink faerie assassin" do
    expect(sower.card.types).to include("Faerie", "Assassin")
    expect(sower.power).to eq(2)
    expect(sower.toughness).to eq(3)
    expect(sower.flying?).to be(true)
    expect(sower.lifelink?).to be(true)
  end

  it "puts a -1/-1 counter on up to one target creature when its controller casts a spell on an opponent's turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase_for!(p2)
    p1.add_mana(red: 1)
    p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!

    game.resolve_choice!(target: bears)
    game.stack.resolve!

    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "does not trigger when its controller casts a spell on their own turn" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase!
    p1.add_mana(red: 1)

    p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }

    expect(game.choices).to be_empty
  end
end
