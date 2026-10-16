# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnvoyOfTheAncestors do
  include_context "two player game"

  let!(:envoy) { ResolvePermanent("Envoy Of The Ancestors", owner: p1) }

  def outlast
    p1.add_mana(white: 1)
    p1.activate_ability(ability: envoy.activated_abilities.first) { |a| a.pay_mana(white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/3 Human Cleric" do
    expect([envoy.power, envoy.toughness]).to eq([2, 3])
    expect(envoy.type?("Cleric")).to be(true)
  end

  context "Outlast {W}" do
    it "taps and puts a +1/+1 counter on it at sorcery speed" do
      go_to_main_phase!
      outlast

      expect(envoy).to be_tapped
      expect([envoy.power, envoy.toughness]).to eq([3, 4])
    end

    it "can't be activated on the opponent's turn" do
      go_to_main_phase_for!(p2)
      p1.add_mana(white: 1)

      expect { p1.activate_ability(ability: envoy.activated_abilities.first) { |a| a.pay_mana(white: 1) } }
        .to raise_error(Magic::IllegalAction)
      expect(envoy.counters).to be_empty
    end
  end

  context "Modified creatures you control have lifelink" do
    before { go_to_main_phase! }

    it "gives lifelink to a creature with a counter (including itself)" do
      outlast
      game.tick!

      expect(envoy).to have_keyword(:lifelink)
    end

    it "gives lifelink to a creature with Equipment attached" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      greaves = ResolvePermanent("Lightning Greaves", owner: p1)
      p1.activate_ability(ability: greaves.activated_abilities.first) { _1.targeting(bears) }
      game.stack.resolve!
      game.tick!

      expect(bears).to have_keyword(:lifelink)
    end

    def enchant_with_capture_sphere(bears, caster:)
      sphere = Card("Capture Sphere", owner: caster)
      caster.add_mana(white: 4)
      game.take_action(cast_action(player: caster, card: sphere).pay_mana(white: 1, generic: { white: 3 }).targeting(bears))
      game.stack.resolve!
      game.tick!
    end

    it "gives lifelink to a creature enchanted by an Aura you control" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      enchant_with_capture_sphere(bears, caster: p1)

      expect(bears.attachments.map(&:name)).to eq(["Capture Sphere"])
      expect(bears).to have_keyword(:lifelink)
    end

    it "does not give lifelink to a creature enchanted only by an opponent's Aura" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      enchant_with_capture_sphere(bears, caster: p2)

      expect(bears.attachments.map(&:name)).to eq(["Capture Sphere"])
      expect(bears.attachments.first.controller).to eq(p2)
      expect(bears).not_to have_keyword(:lifelink)
    end

    it "gives lifelink to a creature equipped with an Equipment an opponent controls" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      greaves = ResolvePermanent("Lightning Greaves", owner: p2)
      greaves.attach_to!(bears)
      game.tick!

      expect(greaves.controller).to eq(p2)
      expect(bears).to have_keyword(:lifelink)
    end

    it "does not give lifelink to an unmodified creature, or to an opponent's modified creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs.add_counter("+1/+1")
      game.tick!

      expect(bears).not_to have_keyword(:lifelink)
      expect(theirs).not_to have_keyword(:lifelink)
      expect(envoy).not_to have_keyword(:lifelink)
    end
  end
end
