# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheLonelyMountain do
  include_context "two player game"

  def dwarf_ability(mountain) = mountain.activated_abilities.find { _1.is_a?(described_class::DwarfAbility) }

  def dwarves =p1.creatures.select { _1.type?("Dwarf") }

  it "enters tapped without an Equipment" do
    mountain = ResolvePermanent("The Lonely Mountain", owner: p1)

    expect(mountain).to be_tapped
  end

  it "enters untapped if you control an Equipment" do
    ResolvePermanent("Well-Worn Spatula", owner: p1)
    mountain = ResolvePermanent("The Lonely Mountain", owner: p1)

    expect(mountain).not_to be_tapped
  end

  it "taps for {R}" do
    mountain = ResolvePermanent("The Lonely Mountain", owner: p1)
    mountain.untap!
    mana_ability = mountain.activated_abilities.find { _1.is_a?(Magic::ManaAbility) }
    p1.activate_ability(ability: mana_ability)

    expect(p1.mana_pool[:red]).to eq(1)
  end

  context "Dwarf ability" do
    before { go_to_main_phase! }

    it "makes a 2/2 red Dwarf for {4}{R}, {T}" do
      mountain = ResolvePermanent("The Lonely Mountain", owner: p1)
      mountain.untap!
      p1.add_mana(red: 5)
      p1.activate_ability(ability: dwarf_ability(mountain)) do
        _1.pay_mana(generic: { red: 4 }, red: 1)
      end
      game.stack.resolve!
      game.tick!

      expect(dwarves.count).to eq(1)
      expect([dwarves.first.power, dwarves.first.toughness]).to eq([2, 2])
      expect(mountain).to be_tapped
    end

    it "costs {1} less for each Equipment you control" do
      2.times { ResolvePermanent("Well-Worn Spatula", owner: p1) }
      mountain = ResolvePermanent("The Lonely Mountain", owner: p1)
      mountain.untap!
      p1.add_mana(red: 3)
      p1.activate_ability(ability: dwarf_ability(mountain)) do
        _1.pay_mana(generic: { red: 2 }, red: 1)
      end
      game.stack.resolve!
      game.tick!

      expect(dwarves.count).to eq(1)
    end
  end
end
