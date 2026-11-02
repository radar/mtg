# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SaradocMasterOfBuckland do
  include_context "two player game"

  def halfling_tokens = p1.creatures.select { _1.token? && _1.type?("Halfling") }

  def pump_ability(saradoc) = saradoc.activated_abilities.find { _1.is_a?(described_class::PumpAbility) }

  def activate(saradoc, tapped)
    p1.activate_ability(ability: pump_ability(saradoc)) { |a| a.pay_multi_tap(tapped) }
    game.stack.resolve!
    game.tick!
  end

  context "entering" do
    it "is a 2/4 that makes a Halfling token when Saradoc himself enters" do
      saradoc = ResolvePermanent("Saradoc Master Of Buckland", owner: p1)

      expect([saradoc.power, saradoc.toughness]).to eq([2, 4])
      expect(halfling_tokens.count).to eq(1)
      expect([halfling_tokens.first.power, halfling_tokens.first.toughness]).to eq([1, 1])
    end

    it "still makes a token when Saradoc enters with power above 2" do
      ResolvePermanent("Glorious Anthem", owner: p1)
      saradoc = ResolvePermanent("Saradoc Master Of Buckland", owner: p1)

      expect(saradoc.power).to eq(3)
      expect(halfling_tokens.count).to eq(1)
    end

    context "with Saradoc in play" do
      let!(:saradoc) { ResolvePermanent("Saradoc Master Of Buckland", owner: p1) }

      it "makes a token when another nontoken creature with power 2 or less enters" do
        ResolvePermanent("Grizzly Bears", owner: p1)

        expect(halfling_tokens.count).to eq(2)
      end

      it "does not trigger for a creature with power 3 or more" do
        ResolvePermanent("Protector Of Gondor", owner: p1)

        expect(halfling_tokens.count).to eq(1)
      end

      it "does not trigger for a token entering" do
        Magic::Tokens::HumanSoldier.new(game: game, owner: p1).resolve!
        game.settle!

        expect(halfling_tokens.count).to eq(1)
      end

      it "does not trigger for an opponent's creature" do
        ResolvePermanent("Grizzly Bears", owner: p2)

        expect(halfling_tokens.count).to eq(1)
        expect(game.choices).to be_empty
      end

      it "does not trigger for a noncreature permanent" do
        ResolvePermanent("Forest", owner: p1)

        expect(halfling_tokens.count).to eq(1)
      end
    end
  end

  context "tap two other untapped Halflings" do
    let!(:saradoc) { ResolvePermanent("Saradoc Master Of Buckland", owner: p1) }
    let!(:hobbit) { ResolvePermanent("Nimble Hobbit", owner: p1) }
    let!(:token) { halfling_tokens.first }

    it "gives Saradoc +2/+0 and lifelink until end of turn" do
      other = halfling_tokens.last
      expect(halfling_tokens.count).to eq(2)

      activate(saradoc, [other, hobbit])

      expect([other, hobbit]).to all(be_tapped)
      expect(saradoc).not_to be_tapped
      expect([saradoc.power, saradoc.toughness]).to eq([4, 4])
      expect(saradoc).to have_keyword(:lifelink)
    end

    it "wears off at end of turn" do
      activate(saradoc, [halfling_tokens.first, hobbit])

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(saradoc.power).to eq(2)
      expect(saradoc).not_to have_keyword(:lifelink)
    end

    it "cannot be paid with only one other Halfling" do
      expect(pump_ability(saradoc).costs.first.can_pay?(p1)).to be(true)
      hobbit.tap!
      expect(pump_ability(saradoc).costs.first.can_pay?(p1)).to be(true)
      halfling_tokens.first.tap!

      expect(pump_ability(saradoc).costs.first.can_pay?(p1)).to be(false)
    end

    it "cannot tap Saradoc himself or a non-Halfling" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)

      expect { activate(saradoc, [saradoc, hobbit]) }.to raise_error(/Tap exactly 2/)
      expect { activate(saradoc, [bears, hobbit]) }.to raise_error(/Tap exactly 2/)
      expect(saradoc.power).to eq(2)
    end

    it "cannot tap an opponent's Halfling" do
      theirs = ResolvePermanent("Nimble Hobbit", owner: p2)

      expect { activate(saradoc, [theirs, hobbit]) }.to raise_error(/Tap exactly 2/)
    end

    it "cannot tap an already tapped Halfling" do
      hobbit.tap!

      expect { activate(saradoc, [hobbit, token]) }.to raise_error(/Tap exactly 2/)
    end
  end
end
