# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TicketBoothTunnelOfHate do
  include_context "two player game"

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  describe "Ticket Booth" do
    before { go_to_main_phase! }

    it "manifests dread when unlocked" do
      room = ResolvePermanent("Ticket Booth Tunnel Of Hate", doors: [:right])
      unlock(room, :left, red: 3)
      game.resolve_choice!(target: game.choices.last.choices.first)

      expect(p1.permanents.count(&:face_down?)).to eq(1)
    end
  end

  describe "Tunnel of Hate" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:room) { ResolvePermanent("Ticket Booth Tunnel Of Hate", doors: [:right]) }

    it "gives target attacking creature double strike whenever you attack" do
      attack_with(bears, other)
      game.resolve_choice!(target: bears)

      expect(bears).to have_keyword(:double_strike)
      expect(other).not_to have_keyword(:double_strike)
    end

    it "doesn't trigger when you don't attack" do
      go_to_main_phase!

      expect(game.choices).to be_empty
    end
  end
end
