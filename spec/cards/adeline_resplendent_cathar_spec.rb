# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdelineResplendentCathar do
  include_context "two player game"

  let!(:adeline) { ResolvePermanent("Adeline, Resplendent Cathar", owner: p1) }

  def humans = p1.creatures.select { _1.name == "Human" && _1.token? }

  it "has vigilance and 4 toughness" do
    expect(adeline.toughness).to eq(4)
    expect(adeline).to have_keyword(:vigilance)
  end

  it "has power equal to the number of creatures you control" do
    game.tick!
    expect(adeline.power).to eq(1)

    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    game.tick!
    expect(adeline.power).to eq(3)
  end

  it "doesn't count the opponent's creatures" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(adeline.power).to eq(1)
  end

  it "creates a 1/1 white Human tapped and attacking when you attack" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: adeline, target: p2)
    current_turn.attackers_declared!

    expect(humans.count).to eq(1)
    expect(humans.first).to be_tapped
    expect(current_turn.attacking?(humans.first)).to be true
    expect([humans.first.power, humans.first.toughness]).to eq([1, 1])
  end

  context "when the opponent controls a planeswalker" do
    let!(:walker) { ResolvePermanent("Ajani, Outland Chaperone", owner: p2) }

    def attack_with_adeline
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: adeline, target: p2)
      current_turn.attackers_declared!
    end

    it "asks whether the Human attacks the player or the planeswalker" do
      attack_with_adeline

      expect(game.choices.last.choices).to contain_exactly(p2, walker)
    end

    it "makes the Human attack the planeswalker when chosen" do
      attack_with_adeline
      game.resolve_choice!(target: walker)

      expect(current_turn.attacking?(humans.first)).to be true
      expect(current_turn.attacks.find { _1.attacker == humans.first }.target).to eq(walker)
    end
  end

  it "makes the Human attack the opponent" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: adeline, target: p2)
    current_turn.attackers_declared!
    game.tick!
    go_to_combat_damage!

    # Adeline (power 2 with the token) and the 1/1 Human.
    expect(p2.life).to eq(20 - 2 - 1)
  end
end
