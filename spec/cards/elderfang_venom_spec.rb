require "spec_helper"

RSpec.describe Magic::Cards::ElderfangVenom do
  include_context "two player game"

  let!(:venom) { ResolvePermanent("Elderfang Venom", owner: p1) }

  context "attacking Elves you control have deathtouch" do
    let!(:elf) { ResolvePermanent("Elvish Warmaster", owner: p1) }
    let!(:non_elf) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      skip_to_combat!
      current_turn.declare_attackers!

      current_turn.declare_attacker(elf, target: p2)
      current_turn.declare_attacker(non_elf, target: p2)

      game.tick!
    end

    it "grants deathtouch to the attacking Elf" do
      expect(elf.deathtouch?).to eq(true)
    end

    it "does not grant deathtouch to a non-Elf attacker" do
      expect(non_elf.deathtouch?).to eq(false)
    end
  end

  context "an Elf you control isn't attacking" do
    let!(:elf) { ResolvePermanent("Elvish Warmaster", owner: p1) }

    it "does not have deathtouch" do
      expect(elf.deathtouch?).to eq(false)
    end
  end

  context "whenever an Elf you control dies" do
    let!(:elf) { ResolvePermanent("Elvish Warmaster", owner: p1) }

    it "each opponent loses 1 life and you gain 1 life" do
      elf.destroy!

      expect(p1.life).to eq(21)
      expect(p2.life).to eq(19)
    end
  end

  context "a non-Elf creature you control dies" do
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "does not drain life" do
      bear.destroy!

      expect(p1.life).to eq(20)
      expect(p2.life).to eq(20)
    end
  end

  context "an Elf an opponent controls dies" do
    let!(:opponents_elf) { ResolvePermanent("Elvish Warmaster", owner: p2) }

    it "does not drain life" do
      opponents_elf.destroy!

      expect(p1.life).to eq(20)
      expect(p2.life).to eq(20)
    end
  end
end
