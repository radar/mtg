# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MammothBellow do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Mammoth Bellow", owner: p1) }

  def elephants = p1.creatures.select { _1.types.include?("Elephant") }

  it "creates a 5/5 green Elephant token" do
    p1.add_mana(green: 3, blue: 1, red: 1)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 2 }, green: 1, blue: 1, red: 1) }
    game.stack.resolve!

    expect(elephants.map { [_1.power, _1.toughness] }).to eq([[5, 5]])
    expect(card.zone).to be_graveyard
  end

  it "can be harmonized from the graveyard for {5}{G}{U}{R}, then is exiled" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.graveyard.add(card)
    p1.add_mana(green: 4, blue: 1, red: 1)

    p1.cast(card: card, harmonize: true) do |a|
      a.harmonize_tap(bear)
      a.pay_mana(generic: { green: 3 }, green: 1, blue: 1, red: 1)
    end
    game.stack.resolve!

    expect(elephants.size).to eq(1)
    expect(card.zone).to be_exile
  end
end
