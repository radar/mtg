# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FirebrandArcher do
  include_context "two player game"
  before { go_to_main_phase! }

  subject(:firebrand_archer) { ResolvePermanent("Firebrand Archer", owner: p1) }

  it "is a 2/1 Human Archer" do
    expect(firebrand_archer.power).to eq(2)
    expect(firebrand_archer.toughness).to eq(1)
    expect(firebrand_archer.type?("Human")).to be true
    expect(firebrand_archer.type?("Archer")).to be true
  end

  context "whenever the controller casts a noncreature spell" do
    let(:bolt) { Card("Lightning Bolt", owner: p1) }

    before do
      firebrand_archer
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
    end

    it "deals 1 damage to each opponent" do
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(16)
    end
  end

  it "does not trigger when the controller casts a creature spell" do
    firebrand_archer

    bear = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bear)
    p1.add_mana(green: 2)

    p1.cast(card: bear) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    expect(p2.life).to eq(20)
  end

  it "does not trigger on an opponent's noncreature spell cast" do
    firebrand_archer

    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)

    p2.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p1) }
    game.stack.resolve!

    expect(p1.life).to eq(17)
  end
end
