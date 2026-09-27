# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Game, "#legal_actions (roadmap C2b)" do
  include_context "two player game"

  it "always includes nil, meaning pass" do
    expect(game.legal_actions(p1)).to include(nil)
  end

  describe "castable spells" do
    let(:bears) { Card("Grizzly Bears", owner: p1) }

    before { p1.hand.add(bears) }

    it "includes an affordable creature in hand during the main phase" do
      go_to_main_phase!
      p1.add_mana(green: 2)

      expect(actions_of(Magic::Actions::Cast, p1).map(&:card)).to include(bears)
    end

    it "excludes it when the player can't pay its cost" do
      go_to_main_phase!

      expect(actions_of(Magic::Actions::Cast, p1).map(&:card)).not_to include(bears)
    end

    it "excludes it outside sorcery-speed timing" do
      p1.add_mana(green: 2)

      expect(actions_of(Magic::Actions::Cast, p1).map(&:card)).not_to include(bears)
    end

    it "excludes a land -- lands are played, not cast" do
      forest = Card("Forest", owner: p1)
      p1.hand.add(forest)
      go_to_main_phase!

      expect(actions_of(Magic::Actions::Cast, p1).map(&:card)).not_to include(forest)
    end
  end

  describe "playable lands" do
    let(:forest) { Card("Forest", owner: p1) }

    before { p1.hand.add(forest) }

    it "includes a land in hand during the main phase" do
      go_to_main_phase!

      expect(actions_of(Magic::Actions::PlayLand, p1).map(&:card)).to include(forest)
    end

    it "excludes it once the player has already played a land this turn" do
      go_to_main_phase!
      p1.play_land(land: forest)

      other_forest = Card("Forest", owner: p1)
      p1.hand.add(other_forest)

      expect(actions_of(Magic::Actions::PlayLand, p1).map(&:card)).not_to include(other_forest)
    end
  end

  describe "activatable abilities" do
    it "includes a permanent's mana ability once it can be activated" do
      permanent = ResolvePermanent("Forest", owner: p1)
      permanent.untap!

      expect(actions_of(Magic::Actions::ActivateAbility, p1).map(&:ability)).to include(permanent.activated_abilities.first)
    end
  end

  describe "attack declarations" do
    let(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "includes an untapped, non-summoning-sick creature attacking an opponent, only in the declare attackers step" do
      bears
      skip_to_combat!
      current_turn.declare_attackers!

      action = actions_of(Magic::Actions::DeclareAttacker, p1).find { |a| a.attacker == bears }
      expect(action).not_to be_nil
      expect(action.target).to eq(p2)
    end

    it "excludes attackers outside the declare attackers step" do
      bears
      skip_to_combat!

      expect(actions_of(Magic::Actions::DeclareAttacker, p1)).to be_empty
    end

    it "excludes a summoning-sick creature" do
      sick_bears = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
      skip_to_combat!
      current_turn.declare_attackers!

      expect(actions_of(Magic::Actions::DeclareAttacker, p1).map(&:attacker)).not_to include(sick_bears)
    end

    it "excludes it for the non-active player" do
      bears
      skip_to_combat!
      current_turn.declare_attackers!

      expect(actions_of(Magic::Actions::DeclareAttacker, p2)).to be_empty
    end
  end

  def actions_of(klass, player)
    game.legal_actions(player).compact.select { |action| action.is_a?(klass) }
  end
end
