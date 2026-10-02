# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BakeIntoAPie do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "destroys target creature and creates a Food token" do
    p1.add_mana(black: 4)
    p1.cast(card: Card("Bake Into A Pie", owner: p1)) { |a| a.pay_mana(generic: { black: 2 }, black: 2).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(bears.card.zone).to be_graveyard
    expect(p1.permanents.by_name("Food").count).to eq(1)
  end
end
