require "spec_helper"

# Roadmap F: rule 613 layers, applied by Permanents::ContinuousEffects. One
# context per layer, plus (at the bottom) the two documented interaction
# cases required by the roadmap's "Done when": a base-P/T setter (7b) and an
# anthem (7c) give the same result regardless of creation order (sublayer
# discipline beats timestamp across sublayers), and two competing base-P/T
# setters (both 7b) resolve to whichever was created later, shown both ways.
RSpec.describe "Continuous effect layers (rule 613)" do
  include_context "two player game"
  before { go_to_main_phase! }

  def enchant_with_kenriths_transformation(target, owner: p1)
    card = Card("Kenrith's Transformation", owner: owner)
    owner.add_mana(green: 2)
    owner.cast(card: card) do |action|
      action.pay_mana(generic: { green: 1 }, green: 1)
      action.targeting(target)
    end
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  describe "layer 1 (copy)" do
    it "a copied permanent's characteristics come from the copied card" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      angel = ResolvePermanent("Baneslayer Angel", owner: p2)

      bears.copied_card = angel.copiable_card
      game.tick!

      expect(bears.power).to eq(angel.power)
      expect(bears.toughness).to eq(angel.toughness)
      expect(bears).to be_flying
    end
  end

  describe "layer 2 (control)" do
    it "reverts every stacked until-end-of-turn control-change effect at cleanup" do
      creature = ResolvePermanent("Grizzly Bears", owner: p1)

      creature.gain_control_until_eot!(p2)
      creature.gain_control_until_eot!(p1)
      expect(creature.controller).to eq(p1)
      expect(creature.control_change_effects.count).to eq(2)

      creature.cleanup!

      expect(creature.controller).to eq(p1)
      expect(creature.control_change_effects).to be_empty
    end
  end

  describe "layer 3 (text-changing)" do
    it "is re-derived from the static ability every pass, not a sticky flag" do
      angel = ResolvePermanent("Baneslayer Angel", owner: p2)
      enchant_with_kenriths_transformation(angel)

      expect(angel).to be_lost_all_abilities
      expect(angel.lost_all_abilities_by_effect).to eq(true)

      game.battlefield.by_name("Kenrith's Transformation").first.destroy!
      game.tick!

      expect(angel).not_to be_lost_all_abilities
    end
  end

  describe "layers 3 and 6 together (613.7: timestamp order)" do
    it "removes an ability granted before 'loses all abilities' and keeps one granted after it" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.grant_keyword(Magic::Cards::Keywords::FLYING)
      game.tick!
      expect(bears).to be_flying

      enchant_with_kenriths_transformation(bears)
      expect(bears).not_to be_flying

      bears.grant_keyword(Magic::Cards::Keywords::REACH)
      game.tick!
      expect(bears).to be_reach
      expect(bears).not_to be_flying
    end
  end

  describe "layer 4 (type-changing)" do
    it "a modifier-granted type and the card's own types both apply" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_types(Magic::Types::Artifact)
      game.tick!

      expect(bears).to be_artifact
      expect(bears).to be_creature
    end
  end

  describe "layer 5 (colour-changing)" do
    it "the higher-timestamp source wins over an earlier one" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.change_colors!([:blue])
      game.tick!
      expect(bears.colors).to eq([:blue])

      enchant_with_kenriths_transformation(bears)

      # Kenrith's Transformation entered after the colour-changing modifier was
      # created, so its (later) timestamp wins.
      expect(bears.colors).to eq([:green])
    end
  end

  describe "layer 6 (ability add/remove)" do
    it "a static keyword grant and a modifier-granted keyword both apply" do
      creature = ResolvePermanent("Grizzly Bears", owner: p1)
      boots = ResolvePermanent("Swiftfoot Boots", owner: p1)
      boots.untap!
      p1.add_mana(generic: 1)
      p1.activate_ability(ability: boots.activated_abilities.first) do |ability|
        ability.targeting(creature)
        ability.pay_mana(generic: { generic: 1 })
      end
      game.stack.resolve!
      game.tick!

      creature.grant_keyword(Magic::Keywords::FIRST_STRIKE)
      game.tick!

      expect(creature).to be_hexproof
      expect(creature.has_keyword?(:haste)).to eq(true)
      expect(creature).to be_first_strike
    end
  end

  describe "layer 7a (characteristic-defining ability)" do
    it "recalculates a dynamic base toughness every pass" do
      daxos = ResolvePermanent("Daxos, Blessed By The Sun", owner: p1)
      expect(daxos.toughness).to eq(p1.devotion(:white))

      ResolvePermanent("Anointed Chorister", owner: p1)
      game.tick!

      expect(daxos.toughness).to eq(p1.devotion(:white))
      expect(daxos.toughness).to eq(3)
    end
  end

  describe "layer 7c (modify, incl. counters and static anthems)" do
    it "stacks a static anthem and a +1/+1 counter additively" do
      ResolvePermanent("Glorious Anthem", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!
      expect(bears.power).to eq(3)

      bears.add_counter("+1/+1")
      game.tick!

      expect(bears.power).to eq(4)
      expect(bears.toughness).to eq(4)
    end
  end

  describe "layer 7d (switch power and toughness)" do
    it "swaps power and toughness after 7c, with an odd number of switches" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.modify_base_power(5)
      bears.modify_base_toughness(2)
      bears.switch_power_and_toughness!
      game.tick!

      expect(bears.power).to eq(2)
      expect(bears.toughness).to eq(5)
    end
  end

  describe "documented interaction cases" do
    it "a base-P/T setter (7b) and an anthem (7c) combine the same way regardless of creation order" do
      anthem_first = ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Glorious Anthem", owner: p1)
      enchant_with_kenriths_transformation(anthem_first)
      expect(anthem_first.power).to eq(4)
      expect(anthem_first.toughness).to eq(4)

      setter_first = ResolvePermanent("Grizzly Bears", owner: p1)
      enchant_with_kenriths_transformation(setter_first)
      expect(setter_first.power).to eq(4)
      expect(setter_first.toughness).to eq(4)
    end

    it "two competing base-P/T setters (both 7b) resolve to whichever was created later, either order" do
      setter_then_modifier = ResolvePermanent("Grizzly Bears", owner: p1)
      enchant_with_kenriths_transformation(setter_then_modifier)
      setter_then_modifier.modify_base_power(5)
      setter_then_modifier.modify_base_toughness(5)
      game.tick!

      expect(setter_then_modifier.power).to eq(5)
      expect(setter_then_modifier.toughness).to eq(5)

      modifier_then_setter = ResolvePermanent("Grizzly Bears", owner: p1)
      modifier_then_setter.modify_base_power(5)
      modifier_then_setter.modify_base_toughness(5)
      enchant_with_kenriths_transformation(modifier_then_setter)

      expect(modifier_then_setter.power).to eq(3)
      expect(modifier_then_setter.toughness).to eq(3)
    end
  end
end
