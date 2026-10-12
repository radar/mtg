# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoilerbilgesRipper do
  include_context "two player game"

  before { go_to_main_phase! }

  def enter_ripper
    card = Card("Boilerbilges Ripper", owner: p1)
    p1.hand.add(card)
    p1.cast(card: card) { |a| a.pay_mana(generic: { red: 4 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4" do
    ripper = ResolvePermanent("Boilerbilges Ripper", owner: p1)

    expect(ripper.power).to eq(4)
    expect(ripper.toughness).to eq(4)
  end

  it "deals 2 damage to any target after sacrificing another creature" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 5)
    enter_ripper
    game.resolve_choice!
    game.resolve_choice!(target: p2)

    expect(p1.creatures.map(&:name)).to eq(["Boilerbilges Ripper"])
    expect(p2.life).to eq(18)
  end

  it "does nothing when the sacrifice is declined" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 5)
    enter_ripper
    game.skip_choice!

    expect(p1.creatures.count).to eq(2)
    expect(p2.life).to eq(20)
  end

  it "has no choice without another creature or enchantment" do
    p1.add_mana(red: 5)
    enter_ripper

    expect(game.choices).to be_empty
  end
end
