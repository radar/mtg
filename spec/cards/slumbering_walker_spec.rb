# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SlumberingWalker do
  include_context "two player game"

  let!(:walker) { ResolvePermanent("Slumbering Walker", owner: p1) }

  def minus_counters = walker.counters.of_type(Magic::Counters::Minus1Minus1).count

  def end_step!
    go_to_main_phase!
    current_turn.end!
    game.settle!
  end

  it "enters with two -1/-1 counters, so a 2/5" do
    expect(minus_counters).to eq(2)
    expect([walker.power, walker.toughness]).to eq([2, 5])
    expect(walker.type?("Giant")).to eq(true)
  end

  context "at the beginning of your end step, with cards in the graveyard" do
    let!(:bears) { Card("Grizzly Bears", owner: p1) } # power 2
    let!(:angel) { Card("Baneslayer Angel", owner: p1) } # power 5

    before do
      p1.graveyard.add(bears)
      p1.graveyard.add(angel)
    end

    it "may remove a counter; when you do, returns a creature card with power 2 or less" do
      end_step!
      expect(game.choices.last).to be_a(described_class::EndStepTrigger::MayChoice)
      game.resolve_choice!

      expect(minus_counters).to eq(1)
      expect(bears.zone).to be_battlefield
      expect(angel.zone).to be_graveyard
    end

    it "does nothing when declined" do
      end_step!
      game.skip_choice!
      expect(minus_counters).to eq(2)
      expect(bears.zone).to be_graveyard
    end

    it "removes any kind of counter" do
      walker.take_counters!(Magic::Counters::Minus1Minus1, amount: 2)
      walker.add_counter("time")
      end_step!
      game.resolve_choice!
      expect(walker.counters.count).to eq(0)
      expect(bears.zone).to be_battlefield
    end
  end

  it "removes the counter even when nothing is eligible to return" do
    p1.graveyard.add(Card("Baneslayer Angel", owner: p1))
    end_step!
    game.resolve_choice!
    expect(minus_counters).to eq(1)
    expect(game.choices).to be_empty
  end

  it "doesn't trigger once it has no counters, or in the opponent's end step" do
    walker.take_counters!(Magic::Counters::Minus1Minus1, amount: 2)
    end_step!
    expect(game.choices).to be_empty

    walker.add_counter("-1/-1")
    game.next_turn
    go_to_main_phase!
    current_turn.end!
    game.settle!
    expect(game.choices).to be_empty
  end
end
