# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SageOfTheFang do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Sage Of The Fang", owner: p1) }

  it "puts a +1/+1 counter on target creature when it enters" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Sage Of The Fang", owner: p1)
    game.resolve_choice!(target: bear)
    game.settle!
    game.tick!

    expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end

  it "renews for {3}{G}: a +1/+1 counter, then doubles the +1/+1 counters on that creature" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    bear.add_counter(Magic::Counters::Plus1Plus1)
    p1.graveyard.add(card)
    p1.add_mana(green: 4)

    p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { green: 3 }, green: 1).targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(card.zone).to be_exile
    expect(bear.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(4)
  end
end
