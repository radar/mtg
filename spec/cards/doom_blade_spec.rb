# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DoomBlade do
  include_context "two player game"

  it "destroys target nonblack creature" do
    target = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 2)
    cast_and_resolve(card: Card("Doom Blade", owner: p1), player: p1) do |action|
      action.targeting(target)
      action.pay_mana(generic: { black: 1 }, black: 1)
    end

    expect(target.card.zone).to be_graveyard
  end

  it "cannot target a black creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    black_target = ResolvePermanent("Juri, Master Of The Revue", owner: p2)
    spell = Card("Doom Blade", owner: p1)

    expect(spell.target_choices).not_to include(black_target)
  end
end
