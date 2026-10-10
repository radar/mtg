# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Murder do
  include_context "two player game"

  it "destroys target creature" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 3)
    cast_and_resolve(card: Card("Murder", owner: p1), player: p1) do |action|
      action.targeting(target)
      action.pay_mana(generic: { black: 1 }, black: 2)
    end

    expect(target.card.zone).to be_graveyard
  end
end
