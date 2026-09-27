# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LochMare do
  include_context "two player game"

  let!(:mare) { ResolvePermanent("Loch Mare", owner: p1) }

  it "is a 4/5 horse serpent that enters with three -1/-1 counters" do
    expect(mare.card.types).to include("Horse", "Serpent")
    expect(mare.power).to eq(1)
    expect(mare.toughness).to eq(2)
  end

  it "draws a card for {1}{U}, remove a counter" do
    p1.add_mana(blue: 2)
    library_count = p1.library.count

    p1.activate_ability(ability: mare.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!

    expect(p1.library.count).to eq(library_count - 1)
    expect(mare.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "taps target creature and puts a stun counter on it for {2}{U}, remove two counters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 3)

    p1.activate_ability(ability: mare.activated_abilities.last) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears).to be_tapped
    expect(bears.counters.of_type(Magic::Counters::Stun).count).to eq(1)
    expect(mare.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end
end
