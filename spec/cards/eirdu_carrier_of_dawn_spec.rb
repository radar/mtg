# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EirduCarrierOfDawn do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:eirdu) { ResolvePermanent("Eirdu, Carrier Of Dawn", owner: p1) }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  it "is a 5/5 flying lifelink legendary Elemental God" do
    expect([eirdu.power, eirdu.toughness]).to eq([5, 5])
    expect(eirdu).to be_flying
    expect(eirdu).to be_lifelink
    expect(eirdu).to be_legendary
    expect(eirdu.card).to be_double_faced
  end

  describe "creature spells you cast have convoke" do
    it "lets you tap a creature to pay {1} of a creature spell" do
      eirdu
      helper = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Courser Of Kruphix", owner: p1) # {1}{G}{G}
      p1.hand.add(spell)
      p1.add_mana(green: 2)

      p1.cast(card: spell) do |action|
        action.convoke(helper)
        action.pay_mana(green: 2)
      end
      game.stack.resolve!

      expect(helper).to be_tapped
      expect(p1.creatures.map(&:name)).to include("Courser of Kruphix")
    end

    it "does not give convoke to noncreature spells" do
      eirdu
      helper = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Lightning Bolt", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(red: 1)

      expect { p1.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end

    it "does not give convoke to your opponent" do
      eirdu
      go_to_main_phase_for!(p2)
      helper = ResolvePermanent("Grizzly Bears", owner: p2)
      spell = Card("Courser Of Kruphix", owner: p2)
      p2.hand.add(spell)

      expect { p2.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end
  end

  describe "transforming" do
    before { eirdu }

    it "may pay {B} at the beginning of your first main phase to transform into Isilu" do
      p1.add_mana(black: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(eirdu.transformed?).to be(true)
      expect(eirdu.name).to eq("Isilu, Carrier of Twilight")
      expect(eirdu.colors).to eq([:black])
      expect(eirdu.mana_value).to eq(5)
      expect([eirdu.power, eirdu.toughness]).to eq([5, 5])
      expect(eirdu).to be_flying
      expect(eirdu).to be_lifelink
    end
  end

  describe "Isilu, Carrier of Twilight" do
    before do
      eirdu.transform!
      game.tick!
    end

    it "no longer grants convoke" do
      helper = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Courser Of Kruphix", owner: p1)
      p1.hand.add(spell)

      expect { p1.cast(card: spell) { _1.convoke(helper) } }.to raise_error(/does not have convoke/)
    end

    it "gives each other nontoken creature you control persist (not tokens, opposing creatures or itself)" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      eirdu.trigger_effect(:create_token, token_class: Magic::Cards::BrigidClachansHeart::KithkinToken)
      game.tick!

      expect(bears).to be_persist
      expect(theirs).not_to be_persist
      expect(eirdu).not_to be_persist
      expect(p1.creatures.find(&:token?)).not_to be_persist
    end

    it "returns a dying creature with a -1/-1 counter" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      game.tick!
      bears.destroy!
      game.settle!

      returned = p1.creatures.find { _1.name == "Courser of Kruphix" }
      expect(returned).not_to be_nil
      expect(returned).not_to equal(bears)
      expect(returned.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    end

    it "does not return a creature that already had a -1/-1 counter" do
      bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
      bears.add_counter(Magic::Counters::Minus1Minus1)
      game.tick!
      bears.destroy!
      game.settle!

      expect(p1.creatures.map(&:name)).not_to include("Courser of Kruphix")
      expect(bears.card.zone).to be_graveyard
    end

    it "may pay {W} to transform back" do
      p1.add_mana(white: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(eirdu.transformed?).to be(false)
      expect(eirdu.name).to eq("Eirdu, Carrier of Dawn")
    end
  end
end
