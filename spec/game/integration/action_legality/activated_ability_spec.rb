require "spec_helper"

RSpec.describe Magic::Game, "action legality -- activating abilities" do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_and_resolve_elves
    card = Card("Llanowar Elves", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 1)
    p1.cast(card: card) { |a| a.auto_pay_mana }
    game.stack.resolve!
    p1.creatures.by_name("Llanowar Elves").first
  end

  context "a creature's {T} ability" do
    it "cannot be activated the turn the creature came under its controller's control" do
      elves = cast_and_resolve_elves

      expect { p1.activate_ability(ability: elves.activated_abilities.first) { _1.choose(:green) } }
        .to raise_error(Magic::IllegalAction, /summoning sick/)
      expect(elves).to be_untapped
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "can be activated on its controller's next turn" do
      elves = cast_and_resolve_elves
      2.times { game.next_turn }
      go_to_main_phase!

      p1.activate_ability(ability: elves.activated_abilities.first) { _1.choose(:green) }

      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "can be activated during the opponent's turn once the creature has been controlled since the controller's last turn began" do
      elves = ResolvePermanent("Llanowar Elves", owner: p1)
      game.next_turn
      go_to_main_phase!

      p1.activate_ability(ability: elves.activated_abilities.first) { _1.choose(:green) }

      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "is not affected by summoning sickness when the creature has haste" do
      elves = cast_and_resolve_elves
      elves.grant_haste!
      game.tick!

      p1.activate_ability(ability: elves.activated_abilities.first) { _1.choose(:green) }

      expect(p1.mana_pool[:green]).to eq(1)
    end
  end

  context "a noncreature permanent's {T} ability" do
    it "can be activated the turn it entered the battlefield" do
      forest = Card("Forest", owner: p1)
      p1.hand.add(forest)
      p1.play_land(land: forest)
      permanent = p1.permanents.by_name("Forest").first

      p1.activate_ability(ability: permanent.activated_abilities.first)

      expect(p1.mana_pool[:green]).to eq(1)
    end
  end

  it "cannot pay a {T} cost twice" do
    forest = ResolvePermanent("Forest", owner: p1)
    p1.activate_ability(ability: forest.activated_abilities.first)

    expect { p1.activate_ability(ability: forest.activated_abilities.first) }
      .to raise_error(Magic::IllegalAction, /already tapped/)
    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cannot be activated by a player who does not control the source" do
    forest = ResolvePermanent("Forest", owner: p1)

    expect { p2.activate_ability(ability: forest.activated_abilities.first) }
      .to raise_error(Magic::IllegalAction, /does not control/)
    expect(p2.mana_pool[:green]).to eq(0)
  end

  it "cannot be activated when the ability's own requirements are not met" do
    speaker = ResolvePermanent("Speaker Of The Heavens", owner: p1)

    expect { p1.activate_ability(ability: speaker.activated_abilities.first) }
      .to raise_error(Magic::IllegalAction, /requirements/)
  end

  it "can be activated when the ability's own requirements are met" do
    speaker = ResolvePermanent("Speaker Of The Heavens", owner: p1)
    p1.gain_life(7)

    p1.activate_ability(ability: speaker.activated_abilities.first)
    game.stack.resolve!

    expect(p1.creatures.by_name("Angel").count).to eq(1)
  end
end
