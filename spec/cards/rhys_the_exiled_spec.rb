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

  describe "{B}, Sacrifice an Elf: Regenerate Rhys" do
    let(:ability) { rhys.activated_abilities.first }

    it "has costs that can be read: mana and a sacrifice of one of your Elves" do
      costs = ability.costs
      expect(costs.map(&:class)).to eq([Magic::Costs::Mana, Magic::Costs::Sacrifice])
      expect(costs.last.choices).to eq([rhys])
    end

    it "lets any Elf you control be sacrificed, but not another type of creature" do
      elf = ResolvePermanent("Elvish Mystic", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      expect(ability.costs.last.choices).to contain_exactly(rhys, elf)
      expect(ability.costs.last.choices).not_to include(bears)
    end

    it "regenerates Rhys" do
      elf = ResolvePermanent("Elvish Mystic", owner: p1)
      p1.add_mana(black: 1)
      p1.activate_ability(ability: ability) do |action|
        action.pay_mana(black: 1)
        action.pay_sacrifice(elf)
      end
      game.stack.resolve!

      expect(game.battlefield.permanents).not_to include(elf)
      expect(game.battlefield.permanents).to include(rhys)
    end
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
