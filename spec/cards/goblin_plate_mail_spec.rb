# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoblinPlateMail do
  include_context "two player game"
  before { go_to_main_phase! }

  def armies = p1.creatures.select { _1.types.include?("Army") }

  it "amasses Goblins 1 and attaches itself to the Army" do
    mail = ResolvePermanent("Goblin Plate Mail", owner: p1)
    game.tick!
    expect(armies.size).to eq(1)
    expect(mail.attached_to).to eq(armies.first)
    expect(armies.first.power).to eq(2)
    expect(armies.first.toughness).to eq(1)
    expect(armies.first.keywords).to include(Magic::Cards::Keywords::MENACE)
  end

  it "puts the counter on an existing Army" do
    ResolvePermanent("Goblin Town Flunkies", owner: p1)
    mail = ResolvePermanent("Goblin Plate Mail", owner: p1)
    game.tick!
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(3)
    expect(mail.attached_to).to eq(armies.first)
  end

  it "equips for {4}" do
    mail = ResolvePermanent("Goblin Plate Mail", owner: p1)
    bear = ResolvePermanent("Large Bear", owner: p1)
    p1.add_mana(red: 4)
    p1.activate_ability(ability: mail.activated_abilities.first) { |a| a.pay_mana(generic: { red: 4 }).targeting(bear) }
    game.stack.resolve!
    game.tick!
    expect(bear.power).to eq(6)
    expect(bear.keywords).to include(Magic::Cards::Keywords::MENACE)
  end
end
