# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IngeniousLeonin do
  include_context "two player game"

  let!(:leonin) { ResolvePermanent("Ingenious Leonin", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:cat) { ResolvePermanent("Bear Cub", owner: p1) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  def attack_with(*creatures)
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  def activate(target)
    p1.add_mana(white: 4)
    p1.activate_ability(ability: leonin.activated_abilities.first) { _1.pay_mana(generic: { white: 3 }, white: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 4/4 Cat Soldier" do
    expect([leonin.power, leonin.toughness]).to eq([4, 4])
  end

  it "puts a +1/+1 counter on another target attacking creature you control" do
    attack_with(leonin, bears)
    activate(bears)

    expect(counters(bears)).to eq(1)
    expect(bears).not_to be_first_strike
  end

  it "gives a Cat first strike until end of turn too" do
    hunter = ResolvePermanent("Helpful Hunter", owner: p1) # a Cat
    attack_with(leonin, hunter)
    activate(hunter)

    expect(counters(hunter)).to eq(1)
    expect(hunter).to be_first_strike
  end

  it "can't target itself" do
    attack_with(leonin, bears)

    expect(leonin.activated_abilities.first.target_choices).not_to include(leonin)
  end

  it "can't target a creature that isn't attacking" do
    attack_with(leonin, bears)

    expect(leonin.activated_abilities.first.target_choices).not_to include(cat)
  end
end
