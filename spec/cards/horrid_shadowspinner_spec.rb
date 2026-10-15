# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HorridShadowspinner do
  include_context "two player game"

  let!(:spinner) { ResolvePermanent("Horrid Shadowspinner", owner: p1) }

  def attack!(creature, player: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    player.declare_attacker(attacker: creature, target: player == p1 ? p2 : p1)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/3 lifelink Horror" do
    expect([spinner.power, spinner.toughness]).to eq([2, 3])
    expect(spinner).to have_keyword(Magic::Cards::Keywords::LIFELINK)
  end

  it "offers to draw cards equal to its power, then discards that many" do
    attack!(spinner)
    hand = p1.hand.count
    expect(game.choices.first).to be_a(Magic::Cards::HorridShadowspinner::DrawThenDiscard)
    game.resolve_choice!(target: spinner)

    expect(p1.hand.count).to eq(hand + 2)
    expect(game.choices.first).to be_a(Magic::Choice::Discard)
    expect(game.choices.first.amount).to eq(2)
    cards = p1.hand.cards.first(2)
    game.resolve_choice!(cards: cards)

    expect(p1.hand.count).to eq(hand)
    expect(cards.map(&:zone)).to all(be_graveyard)
  end

  it "draws equal to the current power" do
    spinner.add_counter("+1/+1")
    game.settle!
    attack!(spinner)
    hand = p1.hand.count
    game.resolve_choice!(target: spinner)

    expect(spinner.power).to eq(3)
    expect(p1.hand.count).to eq(hand + 3)
    expect(game.choices.first.amount).to eq(3)
  end

  it "does nothing when declined" do
    attack!(spinner)
    hand = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand)
    expect(game.choices).to be_empty
  end

  it "does not trigger when another creature attacks" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    attack!(bear)

    expect(game.choices).to be_empty
  end

  it "does not offer the draw to the opponent when only the controller's copy attacks" do
    ResolvePermanent("Horrid Shadowspinner", owner: p2)
    attack!(spinner)

    expect(game.choices.size).to eq(1)
    expect(game.choices.first.actor).to eq(spinner)
  end
end
