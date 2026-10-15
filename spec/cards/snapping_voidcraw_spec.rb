# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SnappingVoidcraw do
  include_context "two player game"

  let!(:voidcraw) { ResolvePermanent("Snapping Voidcraw", owner: p1) }

  it "is a colorless 1/3 (devoid)" do
    expect(voidcraw.colors).to eq([])
    expect(voidcraw.power).to eq(1)
    expect(voidcraw.toughness).to eq(3)
  end

  it "taps for {C}{C}" do
    p1.activate_ability(ability: voidcraw.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(2)
    expect(voidcraw).to be_tapped
  end

  it "draws a card for {3}{C}, {T}" do
    hand_size = p1.hand.count
    p1.add_mana(colorless: 1, red: 3)
    p1.activate_ability(ability: voidcraw.activated_abilities.last) do |ability|
      ability.pay_mana(generic: { red: 3 }, colorless: 1)
    end
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 1)
    expect(voidcraw).to be_tapped
  end

  it "cannot pay the {C} with colored mana" do
    p1.add_mana(red: 4)

    expect do
      p1.activate_ability(ability: voidcraw.activated_abilities.last) do |ability|
        ability.pay_mana(generic: { red: 3 }, colorless: 1)
      end
    end.to raise_error(StandardError)
  end
end
