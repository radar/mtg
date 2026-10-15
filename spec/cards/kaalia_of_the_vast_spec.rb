# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KaaliaOfTheVast do
  include_context "two player game"

  let!(:kaalia) { ResolvePermanent("Kaalia Of The Vast", owner: p1) }
  let(:angel) { Card("Serra Angel", owner: p1).tap { p1.hand.add(_1) } }
  let(:dragon) { Card("Shivan Dragon", owner: p1).tap { p1.hand.add(_1) } }
  let(:demon) { Card("Renegade Demon", owner: p1).tap { p1.hand.add(_1) } }
  let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }

  def attack!(target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: kaalia, target: target)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary 2/2 flying Human Cleric" do
    expect([kaalia.power, kaalia.toughness]).to eq([2, 2])
    expect(kaalia).to have_keyword(Magic::Cards::Keywords::FLYING)
    expect(kaalia.type?("Cleric")).to be(true)
  end

  it "puts an Angel from hand onto the battlefield tapped and attacking" do
    angel
    bears
    attack!
    expect(game.choices.first.choices).to contain_exactly(angel)
    game.resolve_choice!(targets: [angel])

    permanent = p1.permanents.find { _1.card == angel }
    expect(permanent).to be_tapped
    expect(current_turn.combat.attacking?(permanent)).to be(true)
    expect(current_turn.combat.attack_for_attacker(permanent).target).to eq(p2)
    expect(bears.zone).to be_hand
  end

  it "offers Demons and Dragons but not other creatures" do
    demon
    dragon
    bears
    attack!

    expect(game.choices.first.choices).to contain_exactly(demon, dragon)
  end

  it "may decline" do
    angel
    attack!
    game.skip_choice!

    expect(angel.zone).to be_hand
    expect(game.choices).to be_empty
  end

  it "offers nothing without a matching card in hand" do
    bears
    attack!

    expect(game.choices).to be_empty
  end

  it "rejects a card that is not an Angel, Demon or Dragon" do
    angel
    bears
    attack!

    expect { game.resolve_choice!(targets: [bears]) }.to raise_error(ArgumentError)
    expect(bears.zone).to be_hand
  end

  it "does not trigger when another creature attacks" do
    angel
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bear, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices).to be_empty
  end

  it "does not put in cards from the opponent's hand" do
    p2.hand.add(Card("Serra Angel", owner: p2))
    attack!

    expect(game.choices).to be_empty
  end
end
