# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurningCuriosity do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Burning Curiosity", owner: p1) }

  it "exiles the top two cards, which you may play until the end of your next turn" do
    top = p1.library.first(2)
    p1.add_mana(red: 3)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!

    expect(top).to all(satisfy { |c| c.zone.exile? })
    expect(top.map { |c| game.play_permissions.permits?(c, p1) }).to all(be_truthy)
  end

  it "exiles the top three cards if you blighted a creature as the additional cost" do
    top = p1.library.first(3)
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 3)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1).pay_kicker(own_bears) }
    game.stack.resolve!

    expect(top).to all(satisfy { |c| c.zone.exile? })
  end
end
