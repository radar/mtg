# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SurgicalSuiteHospitalRoom do
  include_context "two player game"

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  describe "Surgical Suite" do
    before { go_to_main_phase! }

    let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:big) { Card("Shroudstomper", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:bolt) { Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) } }

    it "returns a creature card with mana value 3 or less from your graveyard to the battlefield" do
      room = ResolvePermanent("Surgical Suite Hospital Room", doors: [:right])
      unlock(room, :left, white: 2)

      expect(bears.zone).to be_battlefield
      expect(big.zone).to be_graveyard
    end

    it "offers only creature cards with mana value 3 or less" do
      Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      room = ResolvePermanent("Surgical Suite Hospital Room", doors: [:right])
      unlock(room, :left, white: 2)

      expect(game.choices.last.choices).to all(satisfy { _1.name == "Grizzly Bears" })
      expect(game.choices.last.choices).not_to include(big, bolt)
    end
  end

  describe "Hospital Room" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:room) { ResolvePermanent("Surgical Suite Hospital Room", doors: [:right]) }

    def attack_with(*attackers)
      skip_to_combat!
      current_turn.declare_attackers!
      attackers.each { current_turn.declare_attacker(_1, target: p2) }
      current_turn.attackers_declared!
      game.settle!
    end

    it "puts a +1/+1 counter on the only attacking creature" do
      attack_with(bears)

      expect([bears.power, other.power]).to eq([3, 2])
    end

    it "puts a +1/+1 counter on the chosen attacking creature" do
      attack_with(bears, other)
      game.resolve_choice!(target: other)

      expect([bears.power, other.power]).to eq([2, 3])
    end
  end
end
