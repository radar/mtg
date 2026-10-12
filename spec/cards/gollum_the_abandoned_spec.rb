# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GollumTheAbandoned do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 2/2 Halfling Horror that can't block" do
    gollum = ResolvePermanent("Gollum The Abandoned", owner: p1)
    expect(gollum.power).to eq(2)
    expect(gollum.type?("Horror")).to eq(true)
    expect(gollum.card.can_block?(double)).to eq(false)
  end

  it "makes each opponent lose 2 life when it enters" do
    expect { ResolvePermanent("Gollum The Abandoned", owner: p1) }.to change { p2.life }.by(-2)
  end

  it "may exile a card from an opponent's graveyard when it enters" do
    target = Card("Large Bear", owner: p2)
    other = Card("Forest", owner: p2)
    p2.graveyard.add(target)
    p2.graveyard.add(other)
    ResolvePermanent("Gollum The Abandoned", owner: p1)
    game.resolve_choice!(target: target)
    expect(target.zone).to be_exile
    expect(other.zone).to be_graveyard
  end

  describe "from the graveyard" do
    let(:card) { Card("Gollum The Abandoned", owner: p1) }
    let!(:fodder) { ResolvePermanent("Large Bear", owner: p1) }

    before { p1.graveyard.add(card) }

    it "returns to hand for {2} and sacrificing an artifact or creature" do
      p1.add_mana(red: 2)
      ability = card.graveyard_abilities.first
      p1.activate_ability(ability: ability) { |a| a.pay_mana(generic: { red: 2 }).pay_sacrifice(fodder) }
      game.stack.resolve!
      expect(card.zone).to be_hand
      expect(p1.graveyard.cards.map(&:name)).to include("Large Bear")
    end
  end
end
