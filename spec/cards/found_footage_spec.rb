# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FoundFootage do
  include_context "two player game"

  let!(:footage) { ResolvePermanent("Found Footage", owner: p1) }

  def activate!
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: footage.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
      a.pay_self_sacrifice
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a Clue artifact for {1}" do
    expect(footage.type?("Artifact")).to be(true)
    expect(footage.type?("Clue")).to be(true)
    expect(Card("Found Footage", owner: p1).cost.cost).to eq(generic: 1)
  end

  it "sacrifices itself, surveils 2, then draws a card" do
    top_two = p1.library.first(2)
    hand = p1.hand.count
    activate!

    expect(footage.card.zone).to be_graveyard
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(2)
    expect(p1.hand.count).to eq(hand)

    game.resolve_choice!(graveyard: [top_two.first], top: [top_two.last])

    expect(p1.graveyard.cards).to include(top_two.first)
    expect(p1.hand.cards).to include(top_two.last)
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "still draws if the surveil is skipped" do
    top = p1.library.first
    hand = p1.hand.count
    activate!
    game.skip_choice!

    expect(p1.hand.cards).to include(top)
    expect(p1.hand.count).to eq(hand + 1)
  end
end
