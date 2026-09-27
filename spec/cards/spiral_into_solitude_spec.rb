# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpiralIntoSolitude do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attach!
    p1.add_mana(white: 2)
    aura = Card("Spiral Into Solitude", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
  end

  it "stops the enchanted creature from attacking or blocking" do
    attach!

    expect(bears.can_attack?).to be(false)
    expect(bears.can_block?(nil)).to be(false)
  end

  it "exiles the enchanted creature for {1}{W}, Blight 1, sacrificing itself" do
    attach!
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    permanent = bears.attachments.first
    p1.add_mana(white: 2)

    p1.activate_ability(ability: permanent.activated_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1).pay_blight(own_bears) }
    game.stack.resolve!

    expect(bears.card.zone).to be_exile
    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end
end
