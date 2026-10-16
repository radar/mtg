# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EmperorOfBones do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:emperor) { ResolvePermanent("Emperor Of Bones", owner: p1) }

  def combat!(player = p1)
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: player))
    game.settle!
  end

  def adapt
    p1.add_mana(black: 2)
    p1.activate_ability(ability: emperor.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 2/2 Skeleton Noble" do
    expect([emperor.power, emperor.toughness]).to eq([2, 2])
    expect(emperor.type?("Skeleton")).to be(true)
  end

  context "at the beginning of combat on your turn, exile up to one target card from a graveyard" do
    let!(:mine) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:theirs) { Card("Llanowar Elves", owner: p2).tap { p2.graveyard.add(_1) } }

    it "can exile a card from your graveyard, remembering it as exiled with the Emperor" do
      combat!
      game.resolve_choice!(target: mine)

      expect(mine.zone).to be_exile
      expect(theirs.zone).to be_graveyard
      expect(emperor.exiled_cards).to include(mine)
    end

    it "can exile a card from an opponent's graveyard" do
      combat!
      game.resolve_choice!(target: theirs)

      expect(theirs.zone).to be_exile
      expect(mine.zone).to be_graveyard
    end

    it "exiles nothing when you decline (up to one)" do
      combat!
      game.skip_choice!

      expect(mine.zone).to be_graveyard
      expect(theirs.zone).to be_graveyard
      expect(emperor.exiled_cards).to be_empty
    end

    it "rejects a card that is not in a graveyard" do
      in_hand = Card("Island", owner: p1)
      p1.hand.add(in_hand)
      combat!

      expect { game.resolve_choice!(target: in_hand) }.to raise_error(ArgumentError)
    end

    it "rejects two cards (only up to one)" do
      combat!

      expect { game.resolve_choice!(target: [mine, theirs]) }.to raise_error(ArgumentError)
    end

    it "does not trigger at the beginning of the opponent's combat" do
      combat!(p2)

      expect(game.choices).to be_empty
    end

    it "does nothing when no graveyard has a card" do
      p1.graveyard.remove(mine)
      p2.graveyard.remove(theirs)
      combat!

      expect(game.choices).to be_empty
    end
  end

  context "{1}{B}: Adapt 2" do
    it "puts two +1/+1 counters on it if it has none" do
      adapt

      expect([emperor.power, emperor.toughness]).to eq([4, 4])
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect(plus_counters(emperor)).to eq(2)
    end

    it "cannot be activated without paying" do
      p1.add_mana(black: 1)

      expect {
        p1.activate_ability(ability: emperor.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(plus_counters(emperor)).to eq(0)
    end
  end

  context "when +1/+1 counters are put on it" do
    let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:land) { Card("Forest", owner: p1).tap { p1.graveyard.add(_1) } }

    it "puts a creature card exiled with it onto the battlefield with a finality counter and haste" do
      combat!
      game.resolve_choice!(target: bears)
      adapt
      game.settle!

      creature = p1.creatures.find { _1.card == bears }
      expect(creature).not_to be_nil
      expect(creature.counters.of_type(Magic::Counters::Finality).count).to eq(1)
      expect(creature).to have_keyword(:haste)
    end

    it "sacrifices it at the beginning of the next end step" do
      combat!
      game.resolve_choice!(target: bears)
      adapt
      game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
      game.settle!

      expect(p1.creatures.map(&:card)).not_to include(bears)
    end

    it "does not return a noncreature card exiled with it" do
      combat!
      game.resolve_choice!(target: land)
      adapt

      expect(p1.permanents.map(&:card)).not_to include(land)
      expect(land.zone).to be_exile
    end

    it "does nothing when nothing has been exiled with it" do
      adapt

      expect(game.choices).to be_empty
      expect(p1.creatures.map(&:card)).not_to include(bears)
    end

    it "does not return a creature exiled by a different Emperor" do
      other = ResolvePermanent("Emperor Of Bones", owner: p1)
      other.exile_with_this!(bears)
      adapt

      expect(p1.creatures.map(&:card)).not_to include(bears)
    end

    it "lets you pick which exiled creature to return" do
      elves = Card("Llanowar Elves", owner: p1).tap { p1.graveyard.add(_1) }
      combat!
      game.resolve_choice!(target: bears)
      combat!
      game.resolve_choice!(target: elves)
      adapt

      expect(game.choices.first.choices).to contain_exactly(bears, elves)
      expect { game.resolve_choice!(target: land) }.to raise_error(ArgumentError)
    end
  end
end
