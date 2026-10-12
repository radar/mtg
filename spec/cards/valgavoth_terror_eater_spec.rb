# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ValgavothTerrorEater do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:valgavoth) { ResolvePermanent("Valgavoth Terror Eater", owner: p1) }

  it "is a 9/9 flying, lifelink Elder Demon" do
    expect([valgavoth.power, valgavoth.toughness]).to eq([9, 9])
    expect(valgavoth).to have_keyword(:flying)
    expect(valgavoth).to have_keyword(:lifelink)
  end

  describe "ward--sacrifice three nonland permanents" do
    let!(:target) { valgavoth }
    let(:spell) { Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) } }

    before do
      game.next_turn
      go_to_main_phase!
      p2.add_mana(red: 1)
      p2.cast(card: spell) { _1.pay_mana(red: 1).targeting(valgavoth) }
      game.settle!
    end

    it "counters the spell unless its caster sacrifices three nonland permanents" do
      expect(game.choices.last).to be_a(Magic::Choice::Ward)
      game.resolve_choice!(sacrifices: [])
      game.stack.resolve!

      expect(valgavoth.damage).to eq(0)
      expect(spell.zone).to be_exile.or be_graveyard
    end

    it "lets the spell resolve when they sacrifice three" do
      three = 3.times.map { ResolvePermanent("Grizzly Bears", owner: p2) }
      game.settle!
      game.skip_choice! while game.choices.any? && !game.choices.last.is_a?(Magic::Choice::Ward)
      game.resolve_choice!(sacrifices: three)

      expect(three.map(&:zone)).to all(be_nil)
    end

    it "won't take lands or fewer than three" do
      lands = 3.times.map { ResolvePermanent("Forest", owner: p2) }
      ward = game.choices.last
      game.resolve_choice!(sacrifices: lands)

      expect(lands.map(&:zone)).to all(be_battlefield)
      expect(ward).to be_a(Magic::Choice::Ward)
    end
  end

  describe "exiling opposing cards" do
    it "exiles a card that would be put into an opponent's graveyard" do
      bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_exile
      expect(valgavoth.exiled_cards).to include(bolt)
    end

    it "exiles an opponent's creature that dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.destroy!
      game.settle!

      expect(bears.card.zone).to be_exile
      expect(valgavoth.exiled_cards).to include(bears.card)
    end

    it "doesn't exile your own cards" do
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      bolt.discard!
      game.settle!

      expect(bolt.zone).to be_graveyard
    end
  end

  describe "playing cards exiled with it" do
    let!(:bolt) do
      Card("Lightning Bolt", owner: p2).tap do
        p2.hand.add(_1)
        _1.discard!
        game.settle!
      end
    end

    it "lets you cast it during your turn by paying life equal to its mana value" do
      life = p1.life
      p1.cast(card: bolt, pay_life: true) { _1.targeting(p2) }
      game.stack.resolve!

      expect(p1.life).to eq(life - 1)
      expect(p2.life).to eq(17)
    end

    it "lets you play an exiled land" do
      forest = Card("Forest", owner: p2).tap { p2.hand.add(_1) }
      forest.discard!
      game.settle!

      p1.play_land(land: forest)

      expect(p1.lands.map(&:card)).to include(forest)
    end

    it "doesn't let you cast it on your opponent's turn" do
      game.next_turn
      go_to_main_phase!

      expect(Magic::Actions::Cast.new(game: game, player: p1, card: bolt, pay_life: true)).not_to be_legal
    end

    it "doesn't let your opponent cast it" do
      game.next_turn
      go_to_main_phase!
      p2.add_mana(red: 1)

      expect(Magic::Actions::Cast.new(game: game, player: p2, card: bolt)).not_to be_legal
    end
  end
end
