# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GollumRiddleMaster do
  include_context "two player game"

  let(:parity) { :odd }
  let!(:gollum) do
    ResolvePermanent("Gollum Riddle Master", owner: p1).tap { game.resolve_choice!(parity: parity) }
  end

  # Lake-town Lookout has mana value 1 (odd), Goblin-town Flunkies 2 (even).
  def opponent_casts_odd
    go_to_main_phase_for!(p2)
    card = Card("Lake Town Lookout", owner: p2)
    p2.hand.add(card)
    p2.add_mana(white: 1)
    p2.cast(card:) { |a| a.pay_mana(white: 1) }
    game.stack.resolve!
    game.settle!
  end

  def opponent_casts_even
    go_to_main_phase_for!(p2)
    card = Card("Goblin Town Flunkies", owner: p2)
    p2.hand.add(card)
    p2.add_mana(red: 2)
    p2.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/1 Halfling Horror" do
    expect(gollum.power).to eq(3)
    expect(gollum.toughness).to eq(1)
    expect(gollum.type?("Horror")).to eq(true)
  end

  it "records the chosen quality as it enters" do
    expect(gollum.card.chosen_parity).to eq(:odd)
  end

  context "choosing odd" do
    it "puts a +1/+1 counter on Gollum when an opponent casts an odd spell and that mode is chosen" do
      opponent_casts_odd
      game.resolve_choice!(mode: :counter)
      expect(gollum.power).to eq(4)
    end

    it "drains each opponent for 2 and gains you 2 with the second mode" do
      opponent_casts_odd
      expect { game.resolve_choice!(mode: :drain) }.to change { p2.life }.by(-2).and change { p1.life }.by(2)
    end

    it "draws a card with the third mode" do
      opponent_casts_odd
      expect { game.resolve_choice!(mode: :draw) }.to change { p1.hand.count }.by(1)
    end

    it "does not trigger on an even spell" do
      opponent_casts_even
      expect(game.choices).to be_empty
    end

    it "does not trigger on your own spells" do
      go_to_main_phase!
      card = Card("Lake Town Lookout", owner: p1)
      p1.hand.add(card)
      p1.add_mana(white: 1)
      p1.cast(card:) { |a| a.pay_mana(white: 1) }
      game.settle!
      expect(game.choices).to be_empty
    end

    it "offers only modes that have not been chosen" do
      opponent_casts_odd
      game.resolve_choice!(mode: :draw)
      game.settle!
      game.stack.resolve! until game.stack.empty?
      opponent_casts_odd
      expect(game.choices.last.choices).to contain_exactly(:counter, :drain)
    end
  end

  context "choosing even" do
    let(:parity) { :even }

    it "triggers on an even spell but not an odd one" do
      opponent_casts_odd
      expect(game.choices).to be_empty
      opponent_casts_even
      expect(game.choices.last.choices).to contain_exactly(:counter, :drain, :draw)
    end
  end
end
