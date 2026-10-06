# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GarruksHarbinger do
  include_context "two player game"

  def p1_library
    [
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      Card("Forest"),
      # End initial card draw
      Card("Island"),
      Card("Grizzly Bears"),
      Card("Garruk, Unleashed"),
      Card("Plains"),
      Card("Forest"),
      Card("Forest"),
    ]
  end

  let!(:harbinger) { ResolvePermanent("Garruks Harbinger", owner: p1) }

  def attack_and_deal_damage
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: harbinger, target: p2)
    go_to_combat_damage!
  end

  it "is a 4/3 Beast with hexproof from black" do
    expect([harbinger.power, harbinger.toughness]).to eq([4, 3])
    expect(harbinger.hexproof_from?(:black)).to eq(true)
    expect(harbinger.hexproof_from?(:red)).to eq(false)
  end

  it "looks at that many cards and offers creature and Garruk cards" do
    attack_and_deal_damage
    game.settle!
    choice = game.choices.last

    expect(choice).to be_a(Magic::Choice::LookAtTopCards)
    expect(choice.looked_at.count).to eq(4)
    expect(choice.choices.map(&:name)).to eq(["Grizzly Bears", "Garruk, Unleashed"])
  end

  it "puts the chosen card in hand and the rest on the bottom" do
    attack_and_deal_damage
    game.settle!
    picked = game.choices.last.choices.last

    expect { game.resolve_choice!(target: picked) }.to change { p1.hand.count }.by(1)
    expect(p1.hand.cards).to include(picked)
    # Island was drawn in the draw step, so the top four were Grizzly Bears, Garruk, Plains and Forest.
    expect(p1.library.last(3).map(&:name)).to contain_exactly("Grizzly Bears", "Plains", "Forest")
  end

  it "does not trigger when it deals damage to a creature" do
    go_to_main_phase_for!(p2)
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
