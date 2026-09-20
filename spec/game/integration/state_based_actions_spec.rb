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

  describe "704.5a: a player with 0 or less life loses" do
    it "loses at 0 life" do
      p1.lose_life(20)
      game.check_state_based_actions!

      expect(p1).to be_lost
      expect(p2).not_to be_lost
    end

    it "does not lose at 1 life" do
      p1.lose_life(19)
      game.check_state_based_actions!

      expect(p1).not_to be_lost
    end
  end

  describe "704.5b: a player who drew from an empty library loses" do
    it "loses the next time state-based actions are checked, not immediately" do
      p1.library.items.clear
      p1.draw!

      expect(p1).not_to be_lost

      game.check_state_based_actions!

      expect(p1).to be_lost
    end
  end

  describe "704.5c: a player with 10 or more poison counters loses" do
    it "loses at 10" do
      p1.add_counter("poison", amount: 10)
      game.check_state_based_actions!

      expect(p1).to be_lost
    end

    it "does not lose at 9" do
      p1.add_counter("poison", amount: 9)
      game.check_state_based_actions!

      expect(p1).not_to be_lost
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

  describe "704.5i: a planeswalker with 0 loyalty is put into the graveyard" do
    let!(:planeswalker) { ResolvePermanent("Ob Nixilis Reignited", owner: p1) }

    it "is put into the graveyard at 0 loyalty" do
      planeswalker.change_loyalty!(-5)
      game.check_state_based_actions!

      expect(planeswalker.zone).to be_nil
      expect(planeswalker.card.zone).to eq(p1.graveyard)
    end

    it "stays with loyalty remaining" do
      planeswalker.change_loyalty!(-4)
      game.check_state_based_actions!

      expect(planeswalker.zone).not_to be_nil
    end
  end

  describe "704.5j: the legend rule" do
    let!(:first) { ResolvePermanent("Abomination of Llanowar", owner: p1) }

    it "asks the controller which of two same-named legendary permanents to keep" do
      second = ResolvePermanent("Abomination of Llanowar", owner: p1)
      game.check_state_based_actions!

      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::LegendRule)
      expect(choice.controller).to eq(p1)
      expect(choice.choices).to contain_exactly(first, second)

      game.resolve_choice!(target: second)

      expect(second.zone).not_to be_nil
      expect(first.zone).to be_nil
      expect(first.card.zone).to eq(p1.graveyard)
    end

    it "does not queue the same choice twice" do
      ResolvePermanent("Abomination of Llanowar", owner: p1)
      game.check_state_based_actions!
      game.check_state_based_actions!

      expect(game.choices.grep(Magic::Choice::LegendRule).count).to eq(1)
    end

    it "does not apply across different controllers" do
      ResolvePermanent("Abomination of Llanowar", owner: p2)
      game.check_state_based_actions!

      expect(game.choices).to be_empty
    end
  end

  describe "704.5m: an Aura that is not attached to anything legal is put into the graveyard" do
    it "is put into the graveyard when its host leaves the battlefield" do
      fetters = ResolvePermanent("Faith's Fetters", owner: p1)
      fetters.attach_to!(bears)
      bears.destroy!
      game.check_state_based_actions!

      expect(fetters.zone).to be_nil
      expect(fetters.card.zone).to eq(p1.graveyard)
    end

    it "stays while its host is still on the battlefield" do
      fetters = ResolvePermanent("Faith's Fetters", owner: p1)
      fetters.attach_to!(bears)
      game.check_state_based_actions!

      expect(fetters.zone).not_to be_nil
    end
  end

  describe "704.5n: Equipment attached to something illegal becomes unattached" do
    let!(:sword) { ResolvePermanent("Short Sword", owner: p1) }

    it "stays on the battlefield, unattached, when its creature leaves" do
      sword.attach_to!(bears)
      bears.destroy!
      game.check_state_based_actions!

      expect(sword.zone).not_to be_nil
      expect(sword.attached_to).to be_nil
    end

    it "moves to a new creature without staying on the old one" do
      elves = ResolvePermanent("Wood Elves", owner: p1)
      sword.attach_to!(bears)
      sword.attach_to!(elves)

      expect(bears.attachments).to be_empty
      expect(elves.attachments).to eq([sword])
    end
  end

  describe "704.5q: +1/+1 and -1/-1 counters cancel in pairs" do
    it "removes as many of each as it can" do
      bears.put_counters!("+1/+1", amount: 3)
      bears.put_counters!("-1/-1", amount: 2)
      game.check_state_based_actions!

      expect(bears.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(0)
      expect(bears.power).to eq(3)
    end

    it "leaves counters of a single kind alone" do
      bears.put_counters!("-1/-1", amount: 1)
      game.check_state_based_actions!

      expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
      expect(bears.power).to eq(1)
    end
  end

  describe "704.5d: a token in a zone other than the battlefield ceases to exist" do
    let(:token_class) do
      Magic::Token.create("Test Soldier") do
        creature_type "Soldier"
        power 1
        toughness 1
      end
    end

    it "ceases to exist in exile" do
      token = token_class.new(game: game, owner: p1, base_power: 1, base_toughness: 1)
      p1.exile.add(token)
      game.check_state_based_actions!

      expect(p1.exile.cards).not_to include(token)
    end
  end
end
