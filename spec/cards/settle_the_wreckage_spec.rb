# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SettleTheWreckage do
  include_context "two player game"

  let(:settle) { Card("Settle The Wreckage", owner: p2) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:ordinary) { ResolvePermanent("Ordinary Bear", owner: p1) }
  let!(:bystander) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.library.add(Card("Forest", owner: p1), 3)
    p1.library.add(Card("Forest", owner: p1), 3)
    p1.library.add(Card("Forest", owner: p1), 3)
    p2.hand.add(settle)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bear, target: p2)
    current_turn.declare_attacker(ordinary, target: p2)
    current_turn.attackers_declared!
    game.settle!
    p2.add_mana(white: 4)
    p2.cast(card: settle) do |action|
      action.pay_mana(generic: { white: 2 }, white: 2)
      action.targeting(p1)
    end
    game.stack.resolve!
    game.settle!
  end

  it "exiles all attacking creatures the target player controls" do
    expect(game.exile.cards).to include(bear.card, ordinary.card)
    expect(p1.creatures).to eq([bystander])
  end

  it "lets that player search for that many basic lands, put onto the battlefield tapped" do
    choice = game.choices.last
    forests = choice.choices.first(2)
    game.resolve_choice!(targets: forests)

    lands = p1.permanents.lands
    expect(lands.count).to eq(2)
    expect(lands).to all(be_tapped)
  end

  it "may find fewer or none" do
    game.resolve_choice!(targets: [])

    expect(p1.permanents.lands.count).to eq(0)
  end

  it "can't find more lands than creatures exiled" do
    choice = game.choices.last

    expect { choice.resolve!(targets: choice.choices.first(3)) }.to raise_error(ArgumentError)
  end
end
