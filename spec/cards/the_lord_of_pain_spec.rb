# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheLordOfPain do
  include_context "two player game"

  let!(:lord) { ResolvePermanent("The Lord Of Pain", owner: p1) }

  def cast_bears!(owner)
    spell = Card("Grizzly Bears", owner: owner).tap { owner.hand.add(_1) } # mana value 2
    owner.add_mana(green: 2)
    owner.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
  end

  it "has menace" do
    expect(lord).to have_keyword(:menace)
  end

  it "stops opponents gaining life but not its controller" do
    p2.gain_life(3)
    p1.gain_life(3)

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(23)
  end

  # With two players the only other player is chosen automatically (a single legal target).
  it "deals damage equal to the mana value of your first spell to the other player" do
    go_to_main_phase!
    cast_bears!(p1)

    expect(p2.life).to eq(18)
  end

  it "triggers for an opponent's first spell, damaging another player" do
    go_to_main_phase_for!(p2)
    cast_bears!(p2)

    expect(p1.life).to eq(18)
    expect(p2.life).to eq(20)
  end

  it "ignores a second spell in the same turn" do
    go_to_main_phase!
    cast_bears!(p1)
    game.stack.resolve!
    game.settle!
    cast_bears!(p1)

    expect(p2.life).to eq(18)
  end
end
