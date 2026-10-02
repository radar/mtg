# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FirespitterWhelp do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:whelp) { ResolvePermanent("Firespitter Whelp", owner: p1) }

  it "is a 2/2 flyer" do
    expect([whelp.power, whelp.toughness]).to eq([2, 2])
    expect(whelp).to be_flying
  end

  it "deals 1 damage to each opponent when you cast a noncreature spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.settle!

    # 3 from Boltwave, 1 from the Whelp
    expect(p2.life).to eq(16)
  end

  it "doesn't trigger on a non-Dragon creature spell" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p2.life).to eq(20)
  end
end
