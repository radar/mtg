# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HorridVigor do
  include_context "two player game"

  it "gives target creature deathtouch and indestructible until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Horrid Vigor", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card: card) do |action|
      action.targeting(bears)
      action.pay_mana(generic: { green: 1 }, green: 1)
    end
    game.stack.resolve!
    game.tick!

    expect(bears).to be_deathtouch
    expect(bears).to be_indestructible
  end
end
