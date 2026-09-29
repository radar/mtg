# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoulbrightSeeker do
  include_context "two player game"

  let!(:seeker) { ResolvePermanent("Soulbright Seeker", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/1 Elemental Sorcerer" do
    expect([seeker.power, seeker.toughness]).to eq([2, 1])
    expect(seeker.type?("Elemental")).to eq(true)
  end

  describe "the additional cost" do
    let(:card) { Card("Soulbright Seeker", owner: p1) }

    before do
      p1.hand.add(card)
      go_to_main_phase!
    end

    it "can behold an Elemental you control" do
      p1.add_mana(red: 1)
      p1.cast(card: card) { |a| a.pay_mana(red: 1).pay_behold(seeker) }
      game.stack.resolve!
      expect(card.zone).to be_battlefield
      expect(seeker.zone).to be_battlefield
    end

    it "can pay {2} instead" do
      p1.add_mana(red: 3)
      p1.cast(card: card) { |a| a.pay_mana(red: 1).pay_behold(generic: { red: 2 }) }
      game.stack.resolve!
      expect(card.zone).to be_battlefield
    end
  end

  describe "the {R} ability" do
    def activate(target)
      p1.add_mana(red: 1)
      p1.activate_ability(ability: seeker.activated_abilities.first) do |ability|
        ability.targeting(target)
        ability.pay_mana(red: 1)
      end
      game.stack.resolve!
    end

    it "gives a creature you control trample until end of turn" do
      activate(bears)
      game.tick!
      expect(bears).to be_trample
      bears.cleanup!
      expect(bears).not_to be_trample
    end

    it "can't target an opponent's creature" do
      rival = ResolvePermanent("Grizzly Bears", owner: p2)
      expect(seeker.activated_abilities.first.target_choices).not_to include(rival)
    end

    it "adds {R}{R}{R}{R} only the third time it resolves in a turn" do
      activate(bears)
      activate(bears)
      expect(p1.mana_pool[:red]).to eq(0)

      activate(bears)
      expect(p1.mana_pool[:red]).to eq(4)

      activate(bears)
      expect(p1.mana_pool[:red]).to eq(4)
    end

    it "starts counting again after the turn ends" do
      2.times { activate(bears) }
      seeker.cleanup!
      2.times { activate(bears) }
      expect(p1.mana_pool[:red]).to eq(0)
    end
  end
end
