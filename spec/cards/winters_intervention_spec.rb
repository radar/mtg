# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WintersIntervention do
  include_context "two player game"

  let!(:cloudkin_seer) { ResolvePermanent("Cloudkin Seer", owner: p2) }

  it "deals 2 damage to the creature and gains 2 life" do
    life = p1.life
    p1.add_mana(black: 2)
    p1.cast(card: Card("Winter's Intervention")) do
      _1.pay_mana(generic: { black: 1 }, black: 1).targeting(cloudkin_seer)
    end
    game.stack.resolve!
    game.tick!

    expect(cloudkin_seer).to be_dead
    expect(p1.life).to eq(life + 2)
  end
end
