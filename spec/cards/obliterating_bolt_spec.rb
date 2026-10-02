# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ObliteratingBolt do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_bolt_at(target)
    p1.add_mana(red: 2)
    p1.cast(card: Card("Obliterating Bolt", owner: p1)) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "deals 4 damage to target creature and exiles it instead of letting it die" do
    cast_bolt_at(rival)

    expect(game.exile.cards).to include(rival.card)
    expect(p2.graveyard.cards).not_to include(rival.card)
  end

  it "can target a creature that survives the damage, which is then exiled if it dies later this turn" do
    big = ResolvePermanent("Fire Elemental", owner: p2) # 5/4: 4 damage kills it exactly
    cast_bolt_at(big)

    expect(game.exile.cards).to include(big.card)
  end
end
