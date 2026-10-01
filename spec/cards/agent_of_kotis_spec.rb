# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AgentOfKotis do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Agent Of Kotis", owner: p1) }

  it "is a 2/1 Human Rogue" do
    permanent = ResolvePermanent("Agent Of Kotis", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 1])
  end

  it "renews for {3}{U}: two +1/+1 counters on target creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(blue: 4)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect([bear.power, bear.toughness]).to eq([4, 4])
  end
end
