# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::PortcullisVine do
  include_context "two player game"

  subject! { ResolvePermanent("Portcullis Vine", owner: p1) }

  it "has defender" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::DEFENDER)
  end

  it "is a 0/3 Plant Wall" do
    expect(subject.power).to eq(0)
    expect(subject.toughness).to eq(3)
    expect(subject.any_type?("Plant")).to be(true)
    expect(subject.any_type?("Wall")).to be(true)
  end

  describe "activated ability" do
    it "draws a card when sacrificing itself" do
      hand_size = p1.hand.cards.count
      p1.add_mana(green: 2)

      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { green: 2 })
        _1.pay_sacrifice(subject)
      end

      game.stack.resolve!
      game.tick!

      expect(p1.hand.cards.count).to eq(hand_size + 1)
      expect(subject.card.zone).to be_graveyard
    end

    it "draws a card when sacrificing another creature with defender" do
      other_defender = ResolvePermanent("Warded Battlements", owner: p1)
      hand_size = p1.hand.cards.count
      p1.add_mana(green: 2)

      ability = subject.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { green: 2 })
        _1.pay_sacrifice(other_defender)
      end

      game.stack.resolve!
      game.tick!

      expect(p1.hand.cards.count).to eq(hand_size + 1)
      expect(other_defender.card.zone).to be_graveyard
      expect(subject.tapped?).to be(true)
    end

    it "lists only creatures with defender as sacrifice choices" do
      ResolvePermanent("Warded Battlements", owner: p1)
      ResolvePermanent("Wood Elves", owner: p1)

      ability = subject.activated_abilities.first
      sacrifice_cost = ability.costs.find { |c| c.is_a?(Magic::Costs::Sacrifice) }

      choice_names = sacrifice_cost.instance_variable_get(:@choices).map(&:name)
      expect(choice_names).to include("Portcullis Vine", "Warded Battlements")
      expect(choice_names).not_to include("Wood Elves")
    end
  end
end
