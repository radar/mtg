# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KomaWorldEater do
  include_context "two player game"

  def coils(player = p1) = player.creatures.select { _1.name == "Koma's Coil" }

  it "is an 8/12 legendary Serpent with trample and ward {4}" do
    koma = ResolvePermanent("Koma, World-Eater", owner: p1)

    expect([koma.power, koma.toughness]).to eq([8, 12])
    expect(koma.type?("Legendary")).to eq(true)
    expect(koma.type?("Serpent")).to eq(true)
    expect(koma).to be_trample
  end

  it "can't be countered" do
    expect(Card("Koma, World-Eater", owner: p1).can_be_countered?).to eq(false)
  end

  describe "combat damage to a player" do
    let!(:koma) { ResolvePermanent("Koma, World-Eater", owner: p1) }

    before do
      go_to_main_phase!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(koma, target: p2)
      current_turn.attackers_declared!
    end

    it "creates four 3/3 blue Serpent tokens named Koma's Coil" do
      go_to_combat_damage!
      game.settle!

      expect(p2.life).to eq(12)
      expect(coils.size).to eq(4)
      expect(coils.map { [_1.power, _1.toughness] }.uniq).to eq([[3, 3]])
      expect(coils.map(&:colors).uniq).to eq([[:blue]])
      expect(coils).to all(satisfy { _1.type?("Serpent") && _1.token? && !_1.type?("Legendary") })
    end

    it "still triggers when trample carries damage past a blocker" do
      blocker = ResolvePermanent("Grizzly Bears", owner: p2)
      current_turn.declare_blocker(blocker, attacker: koma)
      go_to_combat_damage!
      game.settle!

      expect(p2.life).to eq(14) # 8 power, 2 lethal to the blocker, 6 tramples over
      expect(coils.size).to eq(4)
    end

    it "makes no tokens before combat damage is dealt" do
      expect(coils).to be_empty
    end
  end
end
