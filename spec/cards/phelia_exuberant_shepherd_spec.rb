# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PheliaExuberantShepherd do
  include_context "two player game"

  let!(:phelia) { ResolvePermanent("Phelia, Exuberant Shepherd", owner: p1) }

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(phelia, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  def end_step!
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
    game.settle!
  end

  def battlefield_named(name) = game.battlefield.permanents.to_a.detect { |permanent| permanent.name == name }

  it "is a 2/2 legendary Dog with flash" do
    expect([phelia.power, phelia.toughness]).to eq([2, 2])
    expect(phelia.type?("Dog")).to be(true)
    expect(phelia.keywords).to include(Magic::Cards::Keywords::FLASH)
  end

  context "when it attacks" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "exiles up to one other target nonland permanent" do
      attack!
      game.resolve_choice!(target: bears)

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
      expect(bears.zone).to be_nil
    end

    it "returns the card to the battlefield at the next end step, under its owner's control" do
      attack!
      game.resolve_choice!(target: bears)
      end_step!

      returned = battlefield_named("Grizzly Bears")
      expect(returned).not_to be_nil
      expect(returned.controller).to eq(p2)
    end

    it "puts no counter on Phelia when it returns under an opponent's control" do
      attack!
      game.resolve_choice!(target: bears)
      end_step!

      expect(plus_counters(phelia)).to eq(0)
    end

    it "puts a +1/+1 counter on Phelia when it returns under your control" do
      mine = ResolvePermanent("Llanowar Elves", owner: p1)
      attack!
      game.resolve_choice!(target: mine)
      end_step!

      expect(battlefield_named("Llanowar Elves").controller).to eq(p1)
      expect(plus_counters(phelia)).to eq(1)
    end

    it "still returns the card if Phelia has left the battlefield, with no counter" do
      mine = ResolvePermanent("Llanowar Elves", owner: p1)
      attack!
      game.resolve_choice!(target: mine)
      phelia.destroy!
      game.settle!
      end_step!

      expect(battlefield_named("Llanowar Elves")).not_to be_nil
      expect(plus_counters(phelia)).to eq(0)
    end

    it "may choose no target" do
      attack!
      game.skip_choice!
      end_step!

      expect(game.choices).to be_empty
      expect(bears.zone).to eq(game.battlefield)
    end

    it "cannot target a land" do
      forest = ResolvePermanent("Forest", owner: p2)
      attack!

      expect(game.choices.last.choices).to include(bears)
      expect(game.choices.last.choices).not_to include(forest)
    end

    it "cannot target itself" do
      attack!

      expect(game.choices.last.choices).not_to include(phelia)
    end

    it "allows at most one target" do
      expect(described_class::ExileChoice.new(actor: phelia).choice_amount).to eq(0..1)
    end
  end
end
