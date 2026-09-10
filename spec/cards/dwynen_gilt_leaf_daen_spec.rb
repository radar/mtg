# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwynenGiltLeafDaen do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:opponent_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  subject!(:dwynen) { ResolvePermanent("Dwynen, Gilt-Leaf Daen", owner: p1) }

  before { game.tick! }

  it "is a 3/4 legendary Elf Warrior with reach" do
    expect(dwynen.power).to eq(3)
    expect(dwynen.toughness).to eq(4)
    expect(dwynen).to be_legendary
    expect(dwynen).to be_reach
  end

  it "gives other Elf creatures you control +1/+1" do
    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(2)
  end

  it "does not boost itself or opponent Elves" do
    expect(dwynen.power).to eq(3)
    expect(opponent_elves.power).to eq(1)
    expect(opponent_elves.toughness).to eq(1)
  end

  context "when attacking" do
    before { skip_to_combat! }

    it "gains 1 life for each attacking Elf you control" do
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: dwynen, target: p2)
      p1.declare_attacker(attacker: wood_elves, target: p2)

      expect {
        current_turn.attackers_declared!
      }.to change { p1.life }.by(2)
    end

    it "counts only attacking Elves you control" do
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: dwynen, target: p2)

      expect {
        current_turn.attackers_declared!
      }.to change { p1.life }.by(1)
    end
  end
end
