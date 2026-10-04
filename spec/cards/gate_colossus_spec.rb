# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GateColossus do
  include_context "two player game"

  let(:colossus_card) { Card("Gate Colossus", owner: p1) }

  it "is an 8/8 Construct" do
    colossus = ResolvePermanent("Gate Colossus", owner: p1)

    expect([colossus.power, colossus.toughness]).to eq([8, 8])
  end

  describe "affinity for Gates" do
    before do
      go_to_main_phase!
      p1.hand.add(colossus_card)
    end

    it "costs {8} with no Gates" do
      p1.add_mana(green: 7)

      expect(cast_action(card: colossus_card)).not_to be_can_perform
    end

    it "costs {1} less for each Gate you control" do
      2.times { ResolvePermanent("Boros Guildgate", owner: p1) }
      p1.add_mana(green: 6)

      expect(cast_action(card: colossus_card)).to be_can_perform
    end

    it "doesn't count an opponent's Gate or a non-Gate land" do
      ResolvePermanent("Boros Guildgate", owner: p2)
      ResolvePermanent("Forest", owner: p1)
      p1.add_mana(green: 7)

      expect(cast_action(card: colossus_card)).not_to be_can_perform
    end
  end

  describe "can't be blocked by creatures with power 2 or less" do
    let!(:colossus) { ResolvePermanent("Gate Colossus", owner: p1) }

    def attack!
      go_to_main_phase!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(colossus, target: p2)
      current_turn.attackers_declared!
    end

    it "can't be blocked by a 2/2" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      attack!

      expect(current_turn.can_block?(attacker: colossus, blocker: bears)).to eq(false)
    end

    it "can be blocked by a creature with power 3 or more" do
      big = ResolvePermanent("Elvish Regrower", owner: p2)
      attack!

      expect(current_turn.can_block?(attacker: colossus, blocker: big)).to eq(true)
    end
  end

  describe "when a Gate enters under your control while it is in your graveyard" do
    before { p1.graveyard.add(colossus_card) }

    def play_gate(name, owner: p1)
      ResolvePermanent(name, owner: owner, settle: false)
      game.settle!
    end

    it "may be put on top of your library" do
      play_gate("Boros Guildgate")
      game.resolve_choice!

      expect(colossus_card.zone).to be_library
      expect(p1.library.first).to eq(colossus_card)
    end

    it "stays in the graveyard if you decline" do
      play_gate("Boros Guildgate")
      game.skip_choice!

      expect(colossus_card.zone).to be_graveyard
    end

    it "doesn't trigger for a land that isn't a Gate" do
      play_gate("Forest")

      expect(game.choices).to be_empty
      expect(colossus_card.zone).to be_graveyard
    end

    it "doesn't trigger for an opponent's Gate" do
      play_gate("Boros Guildgate", owner: p2)

      expect(game.choices).to be_empty
    end
  end

  it "doesn't trigger from the battlefield" do
    ResolvePermanent("Gate Colossus", owner: p1)
    ResolvePermanent("Boros Guildgate", owner: p1, settle: false)
    game.settle!

    expect(game.choices).to be_empty
  end
end
