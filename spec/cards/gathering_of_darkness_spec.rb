# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GatheringOfDarkness do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Gathering of Darkness") }
  let(:army) { p1.creatures.find { _1.type?("Army") } }

  def cast_it(target = nil)
    p1.add_mana(black: 4)
    p1.cast(card: card) do |action|
      action.targeting(target) if target
      action.pay_mana(generic: { black: 3 }, black: 1)
    end
    game.stack.resolve!
    game.tick!
  end

  it "returns a creature card from your graveyard to your hand and amasses Goblins 3" do
    bears = Card("Grizzly Bears")
    p1.graveyard.add(bears)
    cast_it(bears)

    expect(p1.hand.cards).to include(bears)
    expect(p1.graveyard.cards).not_to include(bears)
    expect([army.power, army.toughness]).to eq([3, 3])
    expect(army.type?("Goblin")).to eq(true)
  end

  it "can be cast with no target and still amasses" do
    cast_it
    expect(army.power).to eq(3)
  end
end
