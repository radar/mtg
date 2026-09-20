require "spec_helper"

RSpec.describe "State-based actions (rule 704)" do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  describe "when they are checked" do
    it "after a spell resolves, without any manual tick!" do
      cast_and_resolve(card: Card("Shock"), player: p2, targeting: bears)

      expect(bears.zone).to be_nil
      expect(bears.card.zone).to eq(p1.graveyard)
    end

    it "not while a choice is still pending, but as soon as the last one is resolved" do
      elves = ResolvePermanent("Wood Elves", owner: p1)
      game.choices.clear
      bears.take_damage(2)
      game.add_choice(Magic::Choice::RingBearer.new(player: p1))

      game.state_based_actions_checkpoint!
      expect(bears.zone).not_to be_nil

      game.resolve_choice!(target: elves)
      expect(bears.zone).to be_nil
    end

    it "again on every check, seeing changes made since the last one" do
      game.check_state_based_actions!
      bears.put_counters!("+1/+1", amount: 1)
      bears.take_damage(2)
      game.check_state_based_actions!

      expect(bears.zone).not_to be_nil

      bears.take_counters!(Magic::Counters::Plus1Plus1, amount: 1)
      game.check_state_based_actions!

      expect(bears.zone).to be_nil
    end
  end

  describe "704.5f: a creature with 0 or less toughness is put into the graveyard" do
    it "puts it into the graveyard" do
      bears.modify_toughness(-2)
      game.check_state_based_actions!

      expect(bears.zone).to be_nil
      expect(bears.card.zone).to eq(p1.graveyard)
    end

    it "is not prevented by indestructible" do
      taunter = ResolvePermanent("Brash Taunter", owner: p1)
      taunter.modify_toughness(-1)
      game.check_state_based_actions!

      expect(taunter.zone).to be_nil
    end
  end

  describe "704.5g: a creature with lethal damage is destroyed" do
    it "is destroyed at damage equal to toughness" do
      bears.take_damage(2)
      game.check_state_based_actions!

      expect(bears.zone).to be_nil
    end

    it "survives damage less than its toughness" do
      bears.take_damage(1)
      game.check_state_based_actions!

      expect(bears.zone).not_to be_nil
    end

    it "survives lethal damage when indestructible" do
      taunter = ResolvePermanent("Brash Taunter", owner: p1)
      taunter.take_damage(5)
      game.check_state_based_actions!

      expect(taunter.zone).not_to be_nil
    end
  end

  describe "704.5h: a creature damaged by a deathtouch source is destroyed" do
    it "is destroyed" do
      bears.mark_for_death!
      game.check_state_based_actions!

      expect(bears.zone).to be_nil
    end

    it "survives when indestructible" do
      taunter = ResolvePermanent("Brash Taunter", owner: p1)
      taunter.mark_for_death!
      game.check_state_based_actions!

      expect(taunter.zone).not_to be_nil
    end
  end
end
