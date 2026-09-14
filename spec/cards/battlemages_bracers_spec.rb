# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BattlemagesBracers do
  include_context "two player game"

  let(:sniper) { ResolvePermanent("Skyway Sniper", owner: p1) }
  let(:bracers) { ResolvePermanent("Battlemage's Bracers", owner: p1) }
  let!(:aven_gagglemaster) { ResolvePermanent("Aven Gagglemaster", owner: p2) }

  def equip!
    p1.add_mana(generic: 2)
    p1.activate_ability(ability: bracers.activated_abilities.first) do |ability|
      ability.targeting(sniper)
      ability.pay_mana(generic: { generic: 2 })
    end
    game.stack.resolve!
    game.tick!
  end

  it "grants haste to the equipped creature" do
    equip!

    expect(sniper.has_keyword?(:haste)).to be(true)
  end

  it "does not grant haste to a creature it isn't equipped to" do
    expect(sniper.has_keyword?(:haste)).to be(false)
  end

  context "whenever a non-mana ability of the equipped creature is activated" do
    before { equip! }

    it "may pay {1} to copy that ability, applying the copy to the original target" do
      p1.add_mana(green: 3, red: 1)
      p1.activate_ability(ability: sniper.activated_abilities.first) do
        _1.pay_mana(green: 1, generic: { green: 2 })
        _1.targeting(aven_gagglemaster)
      end

      game.stack.resolve!
      game.resolve_choice!(payment: { red: 1 })
      game.skip_choice!
      game.stack.resolve!

      expect(aven_gagglemaster.damage).to eq(2)
    end

    it "may choose a new target for the copy" do
      other_flier = ResolvePermanent("Aven Gagglemaster", owner: p2)
      p1.add_mana(green: 3, red: 1)
      p1.activate_ability(ability: sniper.activated_abilities.first) do
        _1.pay_mana(green: 1, generic: { green: 2 })
        _1.targeting(aven_gagglemaster)
      end

      game.stack.resolve!
      game.resolve_choice!(payment: { red: 1 })
      game.resolve_choice!
      game.resolve_choice!(target: other_flier)
      game.stack.resolve!

      expect(aven_gagglemaster.damage).to eq(1)
      expect(other_flier.damage).to eq(1)
    end

    it "does nothing if you decline to pay {1}" do
      p1.add_mana(green: 3)
      p1.activate_ability(ability: sniper.activated_abilities.first) do
        _1.pay_mana(green: 1, generic: { green: 2 })
        _1.targeting(aven_gagglemaster)
      end

      game.stack.resolve!
      game.skip_choice!
      game.stack.resolve!

      expect(aven_gagglemaster.damage).to eq(1)
    end

    it "does not trigger for a mana ability, even on the equipped creature" do
      elves = ResolvePermanent("Llanowar Elves", owner: p1)
      p1.add_mana(generic: 2)
      p1.activate_ability(ability: bracers.activated_abilities.first) do |ability|
        ability.targeting(elves)
        ability.pay_mana(generic: { generic: 2 })
      end
      game.stack.resolve!
      game.tick!

      p1.activate_ability(ability: elves.activated_abilities.first)

      expect(game.choices).to be_empty
    end
  end
end
