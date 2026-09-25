# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ForceOfWill do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:force) { Card("Force of Will", owner: p1) }
  let(:target_spell) { Card("Lightning Bolt", owner: p2) }

  def cast_bolt_at_p1
    p2.add_mana(red: 1)
    p2.cast(card: target_spell) do |action|
      action.pay_mana(red: 1)
      action.targeting(p1)
    end
  end

  before { p1.hand.add(force) }

  it "counters target spell for its mana cost" do
    p2.hand.add(target_spell)
    cast_bolt_at_p1
    spell = game.stack.spells.first

    p1.add_mana(blue: 5)
    p1.cast(card: force) do |action|
      action.pay_mana(generic: { blue: 3 }, blue: 2)
      action.targeting(spell)
    end
    game.stack.resolve!

    expect(target_spell.zone).to be_graveyard
    expect(p1.life).to eq(20)
  end

  describe "alternative cost" do
    let(:blue_card) { Card("Counterspell", owner: p1) }

    before do
      p1.hand.add(blue_card)
      p2.hand.add(target_spell)
      cast_bolt_at_p1
    end

    it "exiles a blue card from hand and pays 1 life instead of mana" do
      spell = game.stack.spells.first

      action = cast_action(card: force, player: p1, alternative: true)
      expect(action.can_perform?).to eq(true)
      action.pay_cost(blue_card)
      action.targeting(spell)
      action.perform
      game.stack.resolve!

      expect(blue_card.zone).to be_exile
      expect(p1.life).to eq(19)
      expect(target_spell.zone).to be_graveyard
    end

    it "cannot be paid without another blue card in hand" do
      p1.hand.remove(blue_card)

      action = Magic::Actions::Cast.new(card: force, player: p1, game: game, alternative: true)
      expect(action.can_perform?).to eq(false)
    end

    it "cannot exile a nonblue card" do
      red_card = Card("Lightning Bolt", owner: p1)
      p1.hand.add(red_card)

      action = Magic::Actions::Cast.new(card: force, player: p1, game: game, alternative: true)
      expect { action.pay_cost(red_card) }.to raise_error(RuntimeError, /Invalid card/)
    end
  end
end
