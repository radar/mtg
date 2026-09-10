# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RhysTheExiled do
  include_context "two player game"

  subject!(:rhys) { ResolvePermanent("Rhys The Exiled", owner: p1) }

  it "is a 3/2 legendary Elf Warrior" do
    expect(rhys).to be_creature
    expect(rhys.power).to eq(3)
    expect(rhys.toughness).to eq(2)
    expect(rhys.legendary?).to eq(true)
    expect(rhys.type?("Elf")).to eq(true)
  end

  context "when Rhys attacks" do
    before { skip_to_combat! }

    it "gains life for each Elf you control" do
      ResolvePermanent("Elvish Mystic", owner: p1)
      ResolvePermanent("Wood Elves", owner: p1)

      current_turn.declare_attackers!
      p1.declare_attacker(attacker: rhys, target: p2)

      expect {
        current_turn.attackers_declared!
      }.to change { p1.life }.by(3)
    end

    it "gains life only for attacking Elves" do
      ResolvePermanent("Elvish Mystic", owner: p1)
      ResolvePermanent("Wood Elves", owner: p1)

      current_turn.declare_attackers!
      p1.declare_attacker(attacker: rhys, target: p2)

      expect {
        current_turn.attackers_declared!
      }.to change { p1.life }.by(3)
    end
  end
end
