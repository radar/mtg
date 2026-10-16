# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArgentDais do
  include_context "two player game"

  let!(:dais) { ResolvePermanent("Argent Dais", owner: p1) }

  def oil = dais.counters.of_type(Magic::Counters["oil"]).count

  def attack_with(*creatures, player: p1)
    go_to_main_phase!
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  def exile!(target, player: p1)
    p1.add_mana(white: 2)
    player.activate_ability(ability: dais.activated_abilities.first) do |action|
      action.targeting(target)
      action.pay_mana(generic: { white: 2 })
    end
    game.stack.resolve!
    game.settle!
  end

  it "is an artifact that enters with two oil counters" do
    expect(dais).to be_artifact
    expect(oil).to eq(2)
  end

  describe "attack trigger" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:bears2) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "puts an oil counter on it when two creatures attack" do
      attack_with(bears, bears2)

      expect(oil).to eq(3)
    end

    it "puts only one counter when three creatures attack" do
      bears3 = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(bears, bears2, bears3)

      expect(oil).to eq(3)
    end

    it "doesn't trigger when only one creature attacks" do
      attack_with(bears)

      expect(oil).to eq(2)
    end
  end

  describe "exile ability" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "exiles another target nonland permanent and its controller draws two" do
      hand = p2.hand.count
      exile!(bears)

      expect(game.exile.cards).to include(bears.card)
      expect(p2.creatures).not_to include(bears)
      expect(p2.hand.count).to eq(hand + 2)
      expect(oil).to eq(0)
      expect(dais).to be_tapped
    end

    it "can target your own permanent, and you draw the two cards" do
      mine = ResolvePermanent("Sol Ring", owner: p1)
      hand = p1.hand.count
      exile!(mine)

      expect(p1.hand.count).to eq(hand + 2)
    end

    it "can't target itself" do
      p1.add_mana(white: 2)
      expect {
        p1.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(dais)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(RuntimeError, /Invalid target/)
    end

    it "can't target a land" do
      land = ResolvePermanent("Island", owner: p2)
      p1.add_mana(white: 2)
      expect {
        p1.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(land)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(RuntimeError, /Invalid target/)
    end

    it "can't target a hexproof permanent" do
      bear = ResolvePermanent("Gigantic Big Bear", owner: p2)
      p1.add_mana(white: 2)

      expect {
        p1.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(bear)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(RuntimeError, /Invalid target/)
    end

    it "needs two oil counters" do
      dais.remove_counter(counter_type: Magic::Counters["oil"], amount: 1)
      game.settle!
      p1.add_mana(white: 2)

      expect {
        p1.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(bears)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(Magic::IllegalAction)
      expect(p2.creatures).to include(bears)
    end

    it "needs {2}" do
      p1.add_mana(white: 1)

      expect {
        p1.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(bears)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "can't be activated by the opponent" do
      p2.add_mana(white: 2)

      expect {
        p2.activate_ability(ability: dais.activated_abilities.first) do |action|
          action.targeting(bears)
          action.pay_mana(generic: { white: 2 })
        end
      }.to raise_error(Magic::IllegalAction, /does not control/)
      expect(p2.creatures).to include(bears)
    end
  end
end
