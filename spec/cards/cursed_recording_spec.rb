# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CursedRecording do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:recording) { ResolvePermanent("Cursed Recording", owner: p1) }

  def time_counters = recording.counters.of_type(Magic::Counters::Time).count

  def cast_bolt!
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.settle!
  end

  it "puts a time counter on itself whenever you cast an instant or sorcery" do
    cast_bolt!

    expect(time_counters).to eq(1)
  end

  it "does not count a creature spell" do
    bear = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bear)
    p1.add_mana(green: 2)
    p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(time_counters).to eq(0)
  end

  it "deals 20 damage to you and removes the counters at seven" do
    6.times { recording.add_counter(Magic::Counters::Time) }
    cast_bolt!

    expect(p1.life).to eq(0)
    expect(time_counters).to eq(0)
  end

  it "copies the next instant or sorcery cast this turn after tapping" do
    p1.activate_ability(ability: recording.activated_abilities.first)
    game.settle!
    cast_bolt!

    game.skip_choice!
    game.stack.resolve!

    expect(p2.life).to eq(20 - 3 - 3)
  end

  it "does not copy a spell if it was not tapped" do
    cast_bolt!
    game.stack.resolve!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(17)
  end
end
