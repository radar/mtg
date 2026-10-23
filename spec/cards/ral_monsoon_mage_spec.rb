# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RalMonsoonMage do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:ral) { ResolvePermanent("Ral, Monsoon Mage", owner: p1) }

  def cast_shock
    p1.add_mana(red: 1)
    shock = Card("Shock", owner: p1)
    p1.hand.add(shock)
    p1.cast(card: shock) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    shock
  end

  it "makes instants and sorceries cost {1} less" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    blade = Card("Doom Blade", owner: p1)
    p1.hand.add(blade)
    game.tick!
    p1.add_mana(black: 1)
    expect { p1.cast(card: blade) { |a| a.pay_mana(black: 1); a.targeting(bears) } }.not_to raise_error
  end

  context "when casting an instant or sorcery on your turn" do
    it "deals 1 damage to the controller on a lost flip" do
      allow(p1).to receive(:flip_coin!).and_return(false)
      cast_shock
      game.settle!
      expect(p1.life).to eq(19)
    end

    it "may flip Ral on a won flip" do
      allow(p1).to receive(:flip_coin!).and_return(true)
      cast_shock
      game.settle!
      game.resolve_choice!
      game.settle!
      walker = game.battlefield.controlled_by(p1).find { _1.name == "Ral, Leyline Prodigy" }
      expect(walker).to be_planeswalker
      expect(walker.loyalty).to eq(3)
    end
  end

  context "when casting an instant on an opponent's turn" do
    it "does not flip a coin or deal damage" do
      go_to_main_phase_for!(p2)
      expect(p1).not_to receive(:flip_coin!)
      cast_shock
      game.settle!
      expect(p1.life).to eq(20)
      expect(game.choices).to be_empty
    end
  end

  context "as a planeswalker" do
    let!(:walker) do
      ral.exile_and_return_transformed!
      game.settle!
      game.battlefield.controlled_by(p1).find { _1.name == "Ral, Leyline Prodigy" }
    end

    def activate(index, &block)
      p1.activate_loyalty_ability(ability: walker.loyalty_abilities[index], &block)
      game.stack.resolve!
      game.settle!
    end

    it "enters with loyalty 2 when no spells were cast" do
      expect(walker.loyalty).to eq(2)
    end

    it "+1 sets up a spell discount" do
      activate(0)
      game.tick!
      expect(walker.loyalty).to eq(3)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      blade = Card("Doom Blade", owner: p1)
      p1.hand.add(blade)
      p1.add_mana(black: 1)
      expect { p1.cast(card: blade) { |a| a.pay_mana(black: 1); a.targeting(bears) } }.not_to raise_error
    end

    it "+1 lasts through the opponent's turn and ends when its controller's next turn begins" do
      activate(0)
      game.next_turn
      expect(current_turn.active_player).to eq(p2)
      expect(walker.state[:discounting]).to be(true)

      game.next_turn
      expect(current_turn.active_player).to eq(p1)
      go_to_main_phase!
      expect(walker.state[:discounting]).to be_falsey
    end

    it "-2 deals 2 damage divided and does not draw without another blue permanent" do
      walker.change_loyalty!(1)
      hand = p1.hand.count
      activate(1) { _1.targeting(p2, p1, distribution: { p2 => 1, p1 => 1 }) }
      expect(p2.life).to eq(19)
      expect(p1.life).to eq(19)
      expect(p1.hand.count).to eq(hand)
    end

    it "-2 puts both points on a single target by default" do
      walker.change_loyalty!(1)
      activate(1) { _1.targeting(p2) }
      expect(p2.life).to eq(18)
    end

    it "-2 needs a division that adds up to 2 among one or two targets" do
      walker.change_loyalty!(1)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      ability = walker.loyalty_abilities[1]

      expect { p1.activate_loyalty_ability(ability: ability) { _1.targeting(p2, bears) } }.to raise_error(/must divide 2/)
      expect { p1.activate_loyalty_ability(ability: ability) { _1.targeting(p2, bears, distribution: { p2 => 2, bears => 1 }) } }.to raise_error(/must divide 2/)
      expect { p1.activate_loyalty_ability(ability: ability) { _1.targeting(p2, bears, p1, distribution: { p2 => 1, bears => 1, p1 => 1 }) } }.to raise_error(/must divide 2/)
    end

    it "-2 draws when another blue permanent is controlled" do
      walker.change_loyalty!(1)
      ResolvePermanent("Dreamtide Whale", owner: p1)
      hand = p1.hand.count
      activate(1) { _1.targeting(p2, distribution: { p2 => 2 }) }
      expect(p2.life).to eq(18)
      expect(p1.hand.count).to eq(hand + 1)
    end

    it "-8 exiles the top eight cards" do
      walker.change_loyalty!(6)
      4.times { p1.library.add(Card("Island", owner: p1)) }
      count = p1.library.count
      activate(2)
      expect(p1.library.count).to eq(count - 8)
    end

    it "-8 lets you cast exiled instants and sorceries free, but not other cards" do
      walker.change_loyalty!(6)
      6.times { p1.library.add(Card("Island", owner: p1)) }
      shock = Card("Shock", owner: p1)
      bears = Card("Grizzly Bears", owner: p1)
      p1.library.add(shock)
      p1.library.add(bears)
      activate(2)

      expect(game.exile.cards).to include(shock, bears)
      expect(game.play_permissions.permits?(shock, p1)).to be(true)
      expect(game.play_permissions.permits?(bears, p1)).to be(false)
    end
  end
end
