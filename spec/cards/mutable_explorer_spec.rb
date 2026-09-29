# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MutableExplorer do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:explorer) { ResolvePermanent("Mutable Explorer", owner: p1) }
  let(:mutavault) { p1.permanents.find { _1.name == "Mutavault" } }

  it "is a 1/1 changeling" do
    expect([explorer.power, explorer.toughness]).to eq([1, 1])
    expect(explorer.type?("Elf")).to be(true)
  end

  it "creates a tapped Mutavault token, a colorless land" do
    expect(mutavault).to be_tapped
    expect(mutavault).to be_land
    expect(mutavault).to be_token
    expect(mutavault).to be_colorless
  end

  it "taps for {C}" do
    mutavault.untap!
    p1.activate_ability(ability: mutavault.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "becomes a 2/2 creature with all creature types until end of turn for {1}" do
    mutavault.untap!
    p1.add_mana(green: 1)
    animate = mutavault.activated_abilities.find { _1.costs.any? { |cost| cost.is_a?(Magic::Costs::Mana) } }
    p1.activate_ability(ability: animate) { _1.pay_mana(generic: { green: 1 }) }
    game.stack.resolve!
    game.tick!

    expect(mutavault).to be_creature
    expect(mutavault).to be_land
    expect([mutavault.power, mutavault.toughness]).to eq([2, 2])
    expect(mutavault.type?("Goblin")).to be(true)
  end

  it "stops being a creature at end of turn" do
    mutavault.untap!
    p1.add_mana(green: 1)
    animate = mutavault.activated_abilities.find { _1.costs.any? { |cost| cost.is_a?(Magic::Costs::Mana) } }
    p1.activate_ability(ability: animate) { _1.pay_mana(generic: { green: 1 }) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(mutavault).not_to be_creature
  end
end
