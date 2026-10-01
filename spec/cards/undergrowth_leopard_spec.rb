# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UndergrowthLeopard do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:leopard) { ResolvePermanent("Undergrowth Leopard", owner: p1) }

  it "is a 2/2 with vigilance" do
    expect([leopard.power, leopard.toughness]).to eq([2, 2])
    expect(leopard.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
  end

  it "sacrifices itself to destroy an artifact" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    p1.add_mana(green: 1)
    p1.activate_ability(ability: leopard.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }).targeting(stone) }
    game.stack.resolve!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Undergrowth Leopard")
    expect(p2.graveyard.cards.map(&:name)).to include("Mind Stone")
  end

  it "can destroy an enchantment" do
    ench = ResolvePermanent("Stormplain Detainment", owner: p2)
    game.skip_choice! if game.choices.any?
    p1.add_mana(green: 1)
    p1.activate_ability(ability: leopard.activated_abilities.first) { |a| a.pay_mana(generic: { green: 1 }).targeting(ench) }
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Stormplain Detainment")
  end
end
