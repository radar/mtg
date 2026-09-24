require 'spec_helper'

RSpec.describe Magic::Cards::ShortSword do
  include_context "two player game"

  subject(:permanent) { ResolvePermanent("Short Sword") }

  context "equips, gives a +1/+1" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "buffs wood elves" do
      p1.add_mana(white: 1)
      p1.activate_ability(ability: permanent.activated_abilities.first) do
        _1.targeting(wood_elves)
        _1.pay_mana(generic: { white: 1 })
      end

      game.stack.resolve!
      game.tick!

      expect(wood_elves.attachments.count).to eq(1)
      expect(wood_elves.attachments.first.name).to eq("Short Sword")
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
    end

    it "can be moved to another creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      [wood_elves, bears].each do |creature|
        p1.add_mana(white: 1)
        p1.activate_ability(ability: permanent.activated_abilities.first) do
          _1.targeting(creature)
          _1.pay_mana(generic: { white: 1 })
        end
        game.stack.resolve!
      end
      game.tick!

      expect(bears.attachments.map(&:name)).to eq(["Short Sword"])
      expect([wood_elves.power, bears.power]).to eq([1, 3])
    end
  end
end
