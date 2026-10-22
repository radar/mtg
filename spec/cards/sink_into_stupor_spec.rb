# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SinkIntoStupor do
  include_context "two player game"

  let(:sink) { Card("Sink Into Stupor", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(sink)
  end

  def cast!(target)
    p1.add_mana(blue: 3)
    action = cast_action(player: p1, card: sink)
    action.pay_mana(generic: { blue: 1 }, blue: 2)
    action.targeting(target)
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  it "is a {1}{U}{U} instant with a land back face" do
    expect(sink.mana_value).to eq(3)
    expect(sink).to be_instant
    expect(sink.back_face.name).to eq("Soporific Springs")
    expect(sink.back_face).to be_land
  end

  describe "targeting" do
    let!(:their_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:their_ring) { ResolvePermanent("Sol Ring", owner: p2) }
    let!(:their_forest) { ResolvePermanent("Forest", owner: p2) }
    let!(:my_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "targets only nonland permanents an opponent controls" do
      expect(sink.target_choices).to contain_exactly(their_bears, their_ring)
    end

    it "returns a permanent to its owner's hand" do
      cast!(their_bears)

      expect(their_bears.zone).to be_nil
      expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "returns a permanent that is not a creature" do
      cast!(their_ring)

      expect(p2.hand.cards.map(&:name)).to include("Sol Ring")
    end
  end

  describe "targeting a spell" do
    let(:bolt) { Card("Shock", owner: p2) }

    before do
      p2.hand.add(bolt)
      p2.add_mana(red: 1)
      p2.cast(card: bolt) do |action|
        action.pay_mana(red: 1)
        action.targeting(p1)
      end
    end

    it "targets an opponent's spell but not its own" do
      expect(sink.target_choices.map(&:card)).to eq([bolt])
    end

    it "returns the spell to its owner's hand without resolving it" do
      spell = game.stack.spells.first
      cast!(spell)

      expect(game.stack.spells).to be_empty
      expect(p2.hand.cards).to include(bolt)
      expect(p1.life).to eq(20)
    end
  end

  describe "played as Soporific Springs" do
    let(:springs) { p1.permanents.by_name("Soporific Springs").first }

    context "paying 3 life" do
      before { p1.play_land(land: sink, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(springs).to be_land
        expect(springs).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {U}" do
        p1.activate_ability(ability: springs.activated_abilities.first)
        expect(p1.mana_pool[:blue]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: sink, face: :back) }

      it "enters tapped, with no life lost" do
        expect(springs).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
