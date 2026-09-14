# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IrencragFeat do
  include_context "two player game"

  let(:irencrag_feat) { Card("Irencrag Feat", owner: p1) }

  it "adds seven red mana" do
    p1.hand.add(irencrag_feat)
    p1.add_mana(red: 4)

    p1.cast(card: irencrag_feat) { |a| a.pay_mana(generic: { red: 1 }, red: 3) }
    game.stack.resolve!

    expect(p1.mana_pool[:red]).to eq(7)
  end
end
