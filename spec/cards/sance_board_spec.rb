# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanceBoard do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:board) { ResolvePermanent("Séance Board", owner: p1) }

  def souls = board.counters.of_type(Magic::Counters::Soul).count

  def end_step!
    current_turn.end!
    game.settle!
  end

  it "has the right name" do
    expect(board.name).to eq("Séance Board")
  end

  it "gets a soul counter at the beginning of an end step if a creature died this turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    end_step!

    expect(souls).to eq(1)
  end

  it "gets no counter if no creature died" do
    end_step!

    expect(souls).to eq(0)
  end

  describe "the mana ability" do
    before { 2.times { board.add_counter("soul") } }

    it "adds X mana of one color, where X is the number of soul counters" do
      p1.activate_ability(ability: board.activated_abilities.first) { _1.choose(:red) }

      expect(p1.restricted_mana.size).to eq(2)
    end

    it "can be spent on an instant" do
      p1.activate_ability(ability: board.activated_abilities.first) { _1.choose(:red) }
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(17)
    end

    it "can't be spent on a creature spell that isn't a Demon or Spirit" do
      p1.activate_ability(ability: board.activated_abilities.first) { _1.choose(:green) }
      bears = Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) }

      expect { p1.cast(card: bears) { _1.pay_mana(generic: { green: 1 }, green: 1) } }.to raise_error(StandardError)
    end

    it "can't be activated with no soul counters" do
      empty = ResolvePermanent("Séance Board", owner: p1)

      expect(empty.activated_abilities.first).not_to be_requirements_met
    end
  end
end
