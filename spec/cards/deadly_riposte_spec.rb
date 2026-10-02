# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeadlyRiposte do
  include_context "two player game"

  let!(:tapped) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:untapped) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { tapped.tap! }

  it "deals 3 damage to target tapped creature and gains you 2 life" do
    p1.add_mana(white: 2)
    p1.cast(card: Card("Deadly Riposte", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(tapped) }
    game.stack.resolve!
    game.tick!

    expect(tapped.card.zone).to be_graveyard
    expect(p1.life).to eq(22)
  end

  it "can't target an untapped creature" do
    p1.add_mana(white: 2)

    expect { p1.cast(card: Card("Deadly Riposte", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(untapped) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
