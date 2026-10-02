# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurglarRat do
  include_context "two player game"

  it "is a 1/1 Rat" do
    rat = ResolvePermanent("Burglar Rat", owner: p1)

    expect([rat.power, rat.toughness]).to eq([1, 1])
  end

  it "makes each opponent discard a card when it enters" do
    ResolvePermanent("Burglar Rat", owner: p1)

    expect { game.resolve_choice!(card: p2.hand.first) }.to change { p2.hand.count }.by(-1)
  end

  it "doesn't make you discard" do
    ResolvePermanent("Burglar Rat", owner: p1)

    expect(game.choices.last.player).to eq(p2)
  end
end
