# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FirdochCore do
  include_context "two player game"

  let!(:core) { ResolvePermanent("Firdoch Core", owner: p1) }
  let(:mana_ability) { core.activated_abilities.first }
  let(:animate_ability) { core.activated_abilities.last }

  it "is a Kindred artifact that isn't a creature, and has every creature type" do
    expect(core).to be_artifact
    expect(core).to be_type(Magic::Types::Kindred)
    expect(core).not_to be_creature
    expect(core).to be_type("Shapeshifter")
    expect(core).to be_type("Elf")
    expect(core).to be_type("Faerie")
  end

  it "taps for one mana of any color" do
    p1.activate_ability(ability: mana_ability) { _1.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)
    expect(core).to be_tapped
  end

  it "becomes a 4/4 artifact creature until end of turn" do
    go_to_main_phase!
    p1.add_mana(red: 4)
    p1.activate_ability(ability: animate_ability) { _1.pay_mana(generic: { red: 4 }) }
    game.stack.resolve!
    game.tick!

    expect(core).to be_creature
    expect(core).to be_artifact
    expect([core.power, core.toughness]).to eq([4, 4])
    expect(core).to be_type("Goblin")

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(core).not_to be_creature
  end
end
