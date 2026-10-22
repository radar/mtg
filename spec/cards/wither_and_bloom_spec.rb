# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WitherAndBloom do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Wither And Bloom", owner: p1) }

  it "gives target creature -3/-3 until end of turn" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(bear) }
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "shrinks until end of turn only" do
    big = ResolvePermanent("Serra Angel", owner: p2)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card: card) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(big) }
    game.stack.resolve!

    expect(big.power).to eq(1)
    current_turn.end!
    current_turn.cleanup!
    expect(big.power).to eq(4)
  end

  describe "from the graveyard" do
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:their_bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      p1.graveyard.add(card)
      p1.add_mana(black: 2)
    end

    def activate(target)
      p1.activate_ability(ability: card.graveyard_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(target) }
    end

    it "exiles itself to put a +1/+1 counter on target creature you control" do
      activate(bear)
      game.stack.resolve!
      game.tick!

      expect(card.zone).to be_exile
      expect([bear.power, bear.toughness]).to eq([3, 3])
    end

    it "cannot target a creature you do not control" do
      expect(card.graveyard_abilities.first.target_choices).to include(bear)
      expect(card.graveyard_abilities.first.target_choices).not_to include(their_bear)
    end

    it "can only be activated at sorcery speed" do
      current_turn.beginning_of_combat!

      expect { activate(bear) }.to raise_error(Magic::IllegalAction)
    end
  end
end
