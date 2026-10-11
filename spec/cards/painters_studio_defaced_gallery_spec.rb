# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PaintersStudioDefacedGallery do
  include_context "two player game"

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  describe "Painter's Studio" do
    before { go_to_main_phase! }

    it "exiles the top two cards of your library, which you may play until the end of your next turn" do
      top = p1.library.first(2)
      room = ResolvePermanent("Painters Studio Defaced Gallery", doors: [:right])
      unlock(room, :left, red: 3)

      expect(top.map(&:zone)).to all(be_exile)
      expect(top.all? { game.play_permissions.permits?(_1, p1) }).to be(true)
    end
  end

  describe "Defaced Gallery" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:idle) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:room) { ResolvePermanent("Painters Studio Defaced Gallery", doors: [:right]) }

    it "gives attacking creatures you control +1/+0 until end of turn whenever you attack" do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bears, target: p2)
      current_turn.declare_attacker(other, target: p2)
      current_turn.attackers_declared!
      game.settle!

      expect([bears.power, other.power, idle.power]).to eq([3, 3, 2])
      bears.cleanup!
      expect(bears.power).to eq(2)
    end
  end
end
