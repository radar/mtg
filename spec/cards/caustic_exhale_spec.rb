# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CausticExhale do
  include_context "two player game"

  let(:card) { Card("Caustic Exhale", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "gives -3/-3 when you behold a Dragon for {B}" do
    dragon = ResolvePermanent("Adult Gold Dragon", owner: p1)
    p1.add_mana(black: 1)
    p1.cast(card: card) { |a| a.pay_mana(black: 1).pay_behold(dragon).targeting(bears) }
    game.stack.resolve!
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "or for {B} plus {1}" do
    p1.add_mana(black: 2)
    p1.cast(card: card) { |a| a.pay_mana(black: 1).pay_behold(generic: { black: 1 }).targeting(bears) }
    game.stack.resolve!
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "needs one or the other" do
    p1.add_mana(black: 1)
    expect { p1.cast(card: card) { |a| a.pay_mana(black: 1).targeting(bears) } }.to raise_error(/Additional costs have not been paid/)
  end
end
