# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SuspendedSentence do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Suspended Sentence", owner: p1).tap { p1.hand.add(_1) } }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "destroys the creature, drains its controller for 3 and exiles itself with three time counters" do
    p1.add_mana(black: 4)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 3 }, black: 1).targeting(victim) }
    game.stack.resolve!
    game.settle!

    expect(victim.zone).to be_nil
    expect(p2.life).to eq(17)
    expect(spell.zone).to be_exile
    expect(spell.time_counters).to eq(3)
  end

  describe "suspend 3--{1}{B}" do
    def suspend!
      p1.add_mana(black: 2)
      p1.suspend(card: spell) { _1.pay_mana(generic: { black: 1 }, black: 1) }
    end

    it "exiles it with three time counters" do
      suspend!

      expect(spell.zone).to be_exile
      expect(spell.time_counters).to eq(3)
    end

    it "removes a counter each of its owner's upkeeps and casts it free when the last goes" do
      suspend!
      go_to_main_phase_for!(p2)
      expect(spell.time_counters).to eq(3) # the opponent's upkeep doesn't count

      [2, 1].each do |remaining|
        go_to_main_phase_for!(p1)
        game.settle!
        expect(spell.time_counters).to eq(remaining)
        go_to_main_phase_for!(p2)
      end

      victim = ResolvePermanent("Grizzly Bears", owner: p2)
      go_to_main_phase_for!(p1)
      game.settle!
      game.resolve_choice!(target: victim) if game.choices.any?
      game.stack.resolve!
      game.settle!

      expect(victim.zone).to be_nil
      expect(spell.zone).to be_exile # it exiles itself with three fresh counters
      expect(spell.time_counters).to eq(3)
    end
  end
end
