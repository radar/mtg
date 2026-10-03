# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HighSocietyHunter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:hunter) { ResolvePermanent("High-Society Hunter", owner: p1) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(hunter, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 5/3 flying Vampire Noble" do
    expect([hunter.power, hunter.toughness]).to eq([5, 3])
    expect(hunter).to be_flying
  end

  describe "when it attacks" do
    it "may sacrifice another creature to put a +1/+1 counter on itself" do
      fodder = ResolvePermanent("Grizzly Bears", owner: p1)
      attack!
      game.resolve_choice!(sacrifice: fodder)
      game.settle!

      expect(p1.creatures).not_to include(fodder)
      expect(counters(hunter)).to eq(1)
      expect(hunter.power).to eq(6)
    end

    it "does nothing when you decline" do
      fodder = ResolvePermanent("Grizzly Bears", owner: p1)
      attack!
      game.skip_choice!

      expect(p1.creatures).to include(fodder)
      expect(counters(hunter)).to eq(0)
    end

    it "offers no sacrifice when it is your only creature" do
      attack!

      expect(game.choices).to be_empty
      expect(counters(hunter)).to eq(0)
    end

    it "can't sacrifice an opponent's creature" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      attack!

      expect(game.choices).to be_empty
    end
  end

  describe "whenever another nontoken creature dies" do
    it "draws a card for your creature dying, which includes the sacrificed one" do
      fodder = ResolvePermanent("Grizzly Bears", owner: p1)
      expect { fodder.destroy!; game.settle! }.to change { p1.hand.count }.by(1)
    end

    it "draws a card for an opponent's creature dying" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      expect { theirs.destroy!; game.settle! }.to change { p1.hand.count }.by(1)
    end

    it "does not draw for a token dying" do
      copy = Magic::Permanent.resolve(game:, owner: p1, card: ResolvePermanent("Grizzly Bears", owner: p2).copiable_card, token: true, copy: true, cast: false)
      expect { copy.destroy!; game.settle! }.not_to(change { p1.hand.count })
    end

    it "does not draw for the Hunter itself dying" do
      expect { hunter.destroy!; game.settle! }.not_to(change { p1.hand.count })
    end
  end
end
