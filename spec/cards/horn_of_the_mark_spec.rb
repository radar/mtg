# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HornOfTheMark do
  include_context "two player game"

  let!(:horn) { ResolvePermanent("Horn Of The Mark", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:bears2) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before { go_to_main_phase! }

  def stack_library(*names)
    names.reverse_each { p1.library.add(Card(_1)) }
  end

  def attack_with(*creatures)
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary artifact" do
    expect(horn).to be_artifact
    expect(horn).to be_legendary
  end

  context "with two creatures attacking" do
    before do
      stack_library("Forest", "Grizzly Bears", "Island", "Forest", "Island", "Swamp")
      attack_with(bears, bears2)
    end

    let(:choice) { game.choices.first }

    it "looks at the top five and offers only creature cards" do
      expect(choice).to be_a(described_class::LookChoice)
      expect(choice.looked_at.map(&:name)).to eq(%w[Forest Grizzly\ Bears Island Forest Island])
      expect(choice.choices.map(&:name)).to eq(["Grizzly Bears"])
    end

    it "puts the chosen creature in hand and the rest on the bottom" do
      picked = choice.choices.first
      game.resolve_choice!(target: picked)

      expect(p1.hand.cards).to include(picked)
      expect(p1.library.first.name).to eq("Swamp")
      expect(p1.library.last(4).map(&:name)).to contain_exactly("Forest", "Island", "Forest", "Island")
    end

    it "may take nothing, putting all five on the bottom" do
      count = p1.library.count
      game.skip_choice!

      expect(p1.library.count).to eq(count)
      expect(p1.library.first.name).to eq("Swamp")
      expect(p1.library.last(5).map(&:name)).to contain_exactly("Forest", "Grizzly Bears", "Island", "Forest", "Island")
    end

    it "does not offer a non-creature card" do
      expect { game.resolve_choice!(target: choice.looked_at.first) }.to raise_error(ArgumentError)
    end
  end

  it "triggers once for three simultaneous attackers" do
    bears3 = ResolvePermanent("Grizzly Bears", owner: p1)
    stack_library("Forest", "Forest", "Forest", "Forest", "Forest", "Forest")
    attack_with(bears, bears2, bears3)

    expect(game.choices.size).to eq(1)
  end

  it "does not trigger when only one creature attacks" do
    stack_library("Forest", "Forest", "Forest", "Forest", "Forest", "Forest")
    count = p1.library.count
    attack_with(bears)

    expect(game.choices).to be_empty
    expect(p1.library.count).to eq(count)
  end

  it "does not trigger when the opponent attacks with two creatures" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs2 = ResolvePermanent("Grizzly Bears", owner: p2)
    game.next_turn
    expect(current_turn.active_player).to eq(p2)
    go_to_main_phase!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(theirs, target: p1)
    current_turn.declare_attacker(theirs2, target: p1)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices).to be_empty
  end
end
