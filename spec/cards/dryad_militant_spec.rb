# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DryadMilitant do
  include_context "two player game"

  let(:bolt) { Card("Burst Lightning", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  it "is a 2/1 Dryad Soldier" do
    militant = ResolvePermanent("Dryad Militant", owner: p1)

    expect([militant.power, militant.toughness]).to eq([2, 1])
  end

  context "with Dryad Militant on the battlefield" do
    let!(:militant) { ResolvePermanent("Dryad Militant", owner: p1) }

    it "exiles an instant instead of putting it into your graveyard when it resolves" do
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(18)
      expect(bolt.zone).to be_exile
      expect(p1.graveyard.cards).to be_empty
    end

    it "exiles an opponent's sorcery too, once it resolves" do
      go_to_main_phase_for!(p2)
      second = Card("Boltwave", owner: p2)
      p2.hand.add(second)
      p2.add_mana(red: 1)
      p2.cast(card: second) { |a| a.pay_mana(red: 1) }
      game.stack.resolve!

      expect(second.zone).to be_exile
    end

    it "exiles an instant that is discarded" do
      p1.hand.add(bolt)
      bolt.discard!

      expect(bolt.zone).to be_exile
    end

    it "leaves other cards alone" do
      p1.hand.add(bears)
      bears.discard!

      expect(bears.zone).to be_graveyard
    end

    it "stops once it leaves the battlefield" do
      militant.sacrifice!
      game.settle!
      p1.hand.add(bolt)
      bolt.discard!

      expect(bolt.zone).to be_graveyard
    end
  end
end
