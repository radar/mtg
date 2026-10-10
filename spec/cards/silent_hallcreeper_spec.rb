# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SilentHallcreeper do
  include_context "two player game"

  let!(:hallcreeper) { ResolvePermanent("Silent Hallcreeper", owner: p1) }

  def hit_player!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hallcreeper, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 1/1 enchantment creature that can't be blocked" do
    expect([hallcreeper.power, hallcreeper.toughness]).to eq([1, 1])
    expect(hallcreeper.card).to be_enchantment
    expect(hallcreeper.can_be_blocked?(ResolvePermanent("Grizzly Bears", owner: p2))).to be(false)
  end

  context "when it deals combat damage to a player" do
    it "offers all three modes" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      hit_player!

      expect(game.choices.last.choices).to contain_exactly(:counters, :draw, :copy)
    end

    it "puts two +1/+1 counters on itself" do
      hit_player!
      game.resolve_choice!(mode: :counters)
      game.tick!

      expect([hallcreeper.power, hallcreeper.toughness]).to eq([3, 3])
    end

    it "draws a card" do
      hit_player!
      expect { game.resolve_choice!(mode: :draw) }.to change { p1.hand.count }.by(1)
    end

    it "becomes a copy of another creature you control" do
      ResolvePermanent("Serra Angel", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
      hit_player!
      game.resolve_choice!(mode: :copy)
      game.resolve_choice!(target: p1.creatures.find { |c| c.name == "Serra Angel" })
      game.tick!

      expect(hallcreeper.name).to eq("Serra Angel")
    end

    it "does not offer the copy mode without another creature" do
      hit_player!

      expect(game.choices.last.choices).to contain_exactly(:counters, :draw)
    end

    it "does not offer a mode that has already been chosen" do
      hallcreeper.choose_mode!(:draw)
      hit_player!

      expect(game.choices.last.choices).to contain_exactly(:counters)
    end

    it "offers nothing once all modes have been chosen" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      %i[counters draw copy].each { |mode| hallcreeper.choose_mode!(mode) }
      hit_player!

      expect(game.choices).to be_empty
    end
  end
end
