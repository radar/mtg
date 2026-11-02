# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QuarrelsEnd do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:spell) { Card("Quarrels End", owner: p1) }
  let!(:fodder) { Card("Island", owner: p1) }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  before do
    p1.hand.add(spell)
    p1.hand.add(fodder)
    p1.add_mana(red: 3)
  end

  it "is a sorcery" do
    expect(spell).to be_sorcery
  end

  it "cannot be cast without discarding a card as an additional cost" do
    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    end.to raise_error("Additional costs have not been paid")
  end

  it "discards a card as an additional cost" do
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1).pay_discard(fodder) }
    expect(fodder.zone).to be_graveyard
    expect(p1.hand).not_to include(fodder)
  end

  it "draws two cards and creates a 1/1 white Human Soldier token" do
    library = p1.library.count
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1).pay_discard(fodder) }
    game.stack.resolve!
    game.tick!

    expect(p1.library.count).to eq(library - 2)
    expect(soldiers(p1).count).to eq(1)
    expect(soldiers(p1).first.type?("Human")).to be(true)
    expect(soldiers(p2)).to be_empty
    expect(spell.zone).to be_graveyard
  end

  it "cannot be cast outside the main phase of its controller's turn" do
    go_to_main_phase_for!(p2)
    expect(current_turn.active_player).to eq(p2)
    expect(current_turn).to be_main_phase
    expect do
      p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1).pay_discard(fodder) }
    end.to raise_error(Magic::IllegalAction, /sorcery/i)
  end
end
