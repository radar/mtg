# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EvershrikesGift do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "gives the enchanted creature +1/+0 and flying" do
    p1.add_mana(white: 1)
    aura = Card("Evershrike's Gift", owner: p1)
    p1.hand.add(aura)
    p1.cast(card: aura) { |a| a.pay_mana(white: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(2)
    expect(bears.flying?).to be(true)
  end

  it "can be returned from the graveyard to hand for {1}{W}, Blight 2, as a sorcery" do
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Evershrike's Gift", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(white: 2)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1).pay_blight(own_bears) }
    game.stack.resolve!

    expect(card.zone).to be_hand
    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "cannot be activated from the graveyard outside a main phase" do
    card = Card("Evershrike's Gift", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(white: 2)
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { white: 1 }, white: 1).pay_blight(ResolvePermanent("Grizzly Bears", owner: p1)) } }
      .to raise_error(Magic::IllegalAction)
  end
end
