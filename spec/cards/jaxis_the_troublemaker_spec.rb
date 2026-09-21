# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JaxisTheTroublemaker do
  include_context "two player game"
  before { go_to_main_phase! }

  subject(:jaxis) { ResolvePermanent("Jaxis, The Troublemaker", owner: p1) }

  it "is a 2/3 legendary Human Warrior" do
    expect(jaxis.power).to eq(2)
    expect(jaxis.toughness).to eq(3)
    expect(jaxis).to be_creature
    expect(jaxis.types).to include("Legendary")
  end

  describe "activated ability" do
    let(:ability) { jaxis.activated_abilities.first }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "cannot target Jaxis itself" do
      expect(ability.target_choices).to contain_exactly(bear)
    end

    it "cannot be activated while the stack isn't empty" do
      shock = Card("Shock", owner: p1)
      p1.hand.add(shock)
      p1.add_mana(red: 1)
      p1.cast(card: shock) do |a|
        a.pay_mana(red: 1)
        a.targeting(p2)
      end

      expect(ability.requirements_met?).to eq(false)

      game.stack.resolve!
      expect(ability.requirements_met?).to eq(true)
    end

    it "creates a hasty token copy of another target creature you control, discarding a card and tapping" do
      discard_card = Card("Forest", owner: p1)
      p1.hand.add(discard_card)
      p1.add_mana(red: 1)

      p1.activate_ability(ability: ability) do |a|
        a.pay_mana(red: 1)
        a.pay_discard(discard_card)
        a.targeting(bear)
      end
      game.stack.resolve!
      game.tick!

      expect(discard_card.zone).to be_graveyard
      expect(jaxis.tapped?).to eq(true)

      copy = p1.creatures.by_name("Grizzly Bears").find(&:token?)
      expect(copy).not_to be_nil
      expect(copy.has_keyword?(:haste)).to eq(true)
    end

    it "sacrifices the token at the beginning of the next end step, drawing a card when it dies" do
      discard_card = Card("Forest", owner: p1)
      p1.hand.add(discard_card)
      p1.add_mana(red: 1)

      p1.activate_ability(ability: ability) do |a|
        a.pay_mana(red: 1)
        a.pay_discard(discard_card)
        a.targeting(bear)
      end
      game.stack.resolve!
      game.tick!

      copy = p1.creatures.by_name("Grizzly Bears").find(&:token?)
      library_count_before = p1.library.count

      game.current_turn.end!

      expect(copy.zone).to be_nil
      expect(p1.library.count).to eq(library_count_before - 1)
    end
  end

  describe "blitz" do
    subject(:card) { Card("Jaxis, The Troublemaker", owner: p1) }

    before { p1.hand.add(card) }

    it "can be cast for {1}{R}, gaining haste" do
      p1.add_mana(generic: 1, red: 1)
      p1.cast(card: card, blitz: true) do |a|
        a.pay_mana(generic: { generic: 1 }, red: 1)
      end
      game.stack.resolve!
      game.tick!

      permanent = p1.permanents.last
      expect(permanent.has_keyword?(:haste)).to eq(true)
    end

    it "sacrifices itself at the beginning of the next end step and draws a card when it dies" do
      p1.add_mana(generic: 1, red: 1)
      p1.cast(card: card, blitz: true) do |a|
        a.pay_mana(generic: { generic: 1 }, red: 1)
      end
      game.stack.resolve!
      game.tick!

      permanent = p1.permanents.last
      library_count_before = p1.library.count

      game.current_turn.end!

      expect(permanent.zone).to be_nil
      expect(p1.library.count).to eq(library_count_before - 1)
    end
  end
end
