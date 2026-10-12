# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WitchsCauldron do
  include_context "two player game"

  let!(:cauldron) { ResolvePermanent("Witch's Cauldron", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gains 1 life and draws a card for sacrificing a creature" do
    hand_size = p1.hand.count
    p1.add_mana(black: 2)
    p1.activate_ability(ability: cauldron.activated_abilities.first) do |a|
      a.pay_mana(generic: { black: 1 }, black: 1)
      a.pay_sacrifice(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand_size + 1)
    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(cauldron).to be_tapped
  end

  it "can't be activated while tapped" do
    cauldron.tap!
    p1.add_mana(black: 2)

    expect do
      p1.activate_ability(ability: cauldron.activated_abilities.first) do |a|
        a.pay_mana(generic: { black: 1 }, black: 1)
        a.pay_sacrifice(bears)
      end
    end.to raise_error(StandardError)
  end
end
