# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OverlordOfTheBoilerbilges do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Overlord Of The Boilerbilges", owner: p1).tap { p1.hand.add(_1) } }

  it "is a 5/5 Avatar Horror enchantment creature that deals 4 damage to any target when it enters" do
    p1.add_mana(red: 6)
    p1.cast(card: card) { _1.pay_mana(generic: { red: 4 }, red: 2) }
    game.stack.resolve!
    game.settle!

    permanent = p1.permanents.find { _1.card == card }
    expect([permanent.power, permanent.toughness]).to eq([5, 5])
    game.resolve_choice!(target: p2)
    expect(p2.life).to eq(16)
  end

  it "can target a creature when cast for its impending cost" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(red: 4)
    p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { red: 2 }, red: 2) }
    game.stack.resolve!
    game.settle!
    game.resolve_choice!(target: bears)
    game.settle!

    expect(bears.zone).to be_nil
    expect(p1.permanents.find { _1.card == card }.counters.of_type(Magic::Counters::Time).count).to eq(4)
  end
end
