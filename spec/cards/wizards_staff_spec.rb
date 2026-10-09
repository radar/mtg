# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WizardsStaff do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:staff) { ResolvePermanent("Wizard's Staff", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def equip(ability_class, target, mana)
    ability = staff.activated_abilities.find { _1.is_a?(ability_class) }
    p1.add_mana(**mana)
    p1.activate_ability(ability: ability) do
      _1.targeting(target)
      _1.pay_mana(generic: mana)
    end
    game.stack.resolve!
    game.tick!
  end

  it "Equip {3} attaches to any creature you control and grants prowess" do
    equip(described_class::EquipAbility, bears, { blue: 3 })

    expect(bears.attachments).to include(staff)
    expect(bears).to have_keyword(:prowess)
  end

  it "Equip Wizard {1} only targets a Wizard" do
    wizard = ResolvePermanent("Erudite Wizard", owner: p1)
    ability = staff.activated_abilities.find { _1.is_a?(described_class::EquipWizardAbility) }

    expect(ability.target_choices).to eq([wizard])
    equip(described_class::EquipWizardAbility, wizard, { blue: 1 })
    expect(wizard.attachments).to include(staff)
  end

  it "the equipped creature gets +1/+1 for a noncreature spell, doubled by the Staff" do
    equip(described_class::EquipAbility, bears, { blue: 3 })
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "doubles another triggered ability of the equipped creature" do
    equip(described_class::EquipAbility, bears, { blue: 3 })
    doubler = game.battlefield.static_abilities.of_type(Magic::Abilities::Static::TriggeredAbilityDoubler).first

    expect(doubler.doubles_trigger_for?(bears, nil)).to eq(true)
    expect(doubler.doubles_trigger_for?(ResolvePermanent("Grizzly Bears", owner: p1), nil)).to eq(false)
  end

  it "does not give prowess to an unequipped creature" do
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
