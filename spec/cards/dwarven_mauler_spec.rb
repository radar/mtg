# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwarvenMauler do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mauler) { ResolvePermanent("Dwarven Mauler", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:sword) { ResolvePermanent("Short Sword", owner: p1) }
  let!(:spear) { ResolvePermanent("Ragged Short Spear", owner: p1) }

  before do
    game.skip_choice! if game.choices.any?
    game.tick!
  end

  it "is a 2/1 Dwarf Warrior" do
    expect([mauler.power, mauler.toughness]).to eq([2, 1])
    expect(mauler.type?("Dwarf")).to eq(true)
  end

  it "makes equip abilities that target it cost {2} less (equip {3} costs {1})" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: spear.activated_abilities.first) do
      _1.targeting(mauler)
      _1.pay_mana(generic: { red: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect(spear.attached_to).to eq(mauler)
  end

  it "never reduces generic mana below zero (equip {1} costs nothing)" do
    p1.activate_ability(ability: sword.activated_abilities.first) do
      _1.targeting(mauler)
    end
    game.stack.resolve!
    game.tick!

    expect(sword.attached_to).to eq(mauler)
  end

  it "doesn't reduce equip abilities that target another creature" do
    p1.add_mana(red: 1)
    expect do
      p1.activate_ability(ability: spear.activated_abilities.first) do
        _1.targeting(bears)
        _1.pay_mana(generic: { red: 1 })
      end
    end.to raise_error(StandardError)
  end

  it "doesn't help an opponent's equip" do
    opp_sword = ResolvePermanent("Short Sword", owner: p2)
    opp_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ability = opp_sword.activated_abilities.first
    action = Magic::Actions::ActivateAbility.new(ability: ability, player: p2, game: game)
    action.targeting(opp_bears)
    expect(action.costs.first.cost).to eq({ generic: 1 })
  end
end
