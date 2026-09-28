# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IllusionSpinners do
  include_context "two player game"

  let(:card) { Card("Illusion Spinners", owner: p1) }

  it "is a 4/3 flyer" do
    permanent = ResolvePermanent("Illusion Spinners", owner: p1)

    expect(permanent.power).to eq(4)
    expect(permanent.toughness).to eq(3)
    expect(permanent).to be_flying
  end

  it "cannot be cast at instant speed without a Faerie" do
    p1.add_mana(blue: 5)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { blue: 4 }, blue: 1) } }.to raise_error(Magic::IllegalAction)
  end

  it "can be cast as though it had flash if you control a Faerie" do
    ResolvePermanent("Illusion Spinners", owner: p1)
    p1.add_mana(blue: 5)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 4 }, blue: 1) }
    game.stack.resolve!

    expect(p1.creatures.count { |c| c.name == "Illusion Spinners" }).to eq(2)
  end

  it "does not get flash from an opponent's Faerie" do
    ResolvePermanent("Illusion Spinners", owner: p2)
    p1.add_mana(blue: 5)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { blue: 4 }, blue: 1) } }.to raise_error(Magic::IllegalAction)
  end

  context "hexproof as long as it's untapped" do
    let(:permanent) { ResolvePermanent("Illusion Spinners", owner: p1) }
    let(:bolt) { Card("Lightning Bolt", owner: p2) }

    it "has hexproof while untapped" do
      permanent
      game.tick!

      expect(permanent.can_be_targeted_by?(bolt, controller: p2)).to be(false)
      expect(permanent.can_be_targeted_by?(Card("Lightning Bolt", owner: p1), controller: p1)).to be(true)
    end

    it "loses hexproof while tapped" do
      permanent.tap!
      game.tick!

      expect(permanent.can_be_targeted_by?(bolt, controller: p2)).to be(true)
    end
  end
end
