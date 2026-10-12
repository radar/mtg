# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrrsMap do
  include_context "two player game"

  it "searches for a basic land when it enters" do
    ResolvePermanent("Thrór's Map", owner: p1)

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    land = choice.choices.first
    game.resolve_choice!(targets: [land])

    expect(p1.hand.cards).to include(land)
  end

  it "loots for {2}, {T}" do
    map = ResolvePermanent("Thrór's Map", owner: p1)
    game.skip_choice!
    p1.add_mana(colorless: 2)
    hand_before = p1.hand.count
    p1.activate_ability(ability: map.activated_abilities.first) do
      _1.pay_mana(generic: { colorless: 2 })
    end
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_before + 1)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end
end
