require "spec_helper"

RSpec.describe Magic::Cards::GhoulishImpetus do
  include_context "two player game"
  before { go_to_main_phase! }

  def enchant(creature)
    aura = Card("Ghoulish Impetus", owner: p1)
    p1.hand.add(aura)
    p1.add_mana(black: 3)
    p1.cast(card: aura) do |action|
      action.targeting(creature)
      action.pay_mana(black: 1, generic: { black: 2 })
    end
    game.stack.resolve!
    game.tick!
    aura
  end

  it "grants +1/+1 and deathtouch to an enchanted creature" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    enchant(creature)

    expect(creature.power).to eq(3)
    expect(creature).to be_deathtouch
  end

  it "goads the enchanted creature, so it has to attack" do
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(creature).not_to be_must_attack

    enchant(creature)

    expect(creature).to be_must_attack
  end

  it "returns to the battlefield at the next end step when the enchanted creature dies" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    survivor = ResolvePermanent("Wood Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)
    aura = enchant(creature)

    creature.destroy!
    game.settle!
    expect(aura.zone).to be_graveyard

    current_turn.beginning_of_combat!
    current_turn.end!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::AttachReturningAura)
    game.resolve_choice!(target: survivor)

    expect(survivor.attachments.map(&:name)).to eq(["Ghoulish Impetus"])
  end
end
