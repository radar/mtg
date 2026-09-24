require "spec_helper"

RSpec.describe Magic::Cards::FightRigging do
  include_context "two player game"

  def p1_library
    # The first seven cards are the opening hand.
    [*Array.new(7) { Card("Forest") }, Card("Grizzly Bears"), *Array.new(19) { Card("Forest") }]
  end

  let!(:rigging) { ResolvePermanent("Fight Rigging", owner: p1) }
  let(:bears) { rigging_choice.choices.find { _1.name == "Grizzly Bears" } }
  let(:rigging_choice) { game.choices.last }

  it "hideaway 5: looks at the top five cards" do
    expect(rigging_choice).to be_a(described_class::HideawayChoice)
    expect(rigging_choice.choices.count).to eq(5)
    expect(rigging_choice.choices.first.name).to eq("Grizzly Bears")
  end

  it "exiles the chosen card and puts the other four on the bottom of the library" do
    other_four = rigging_choice.choices - [bears]
    expect { game.resolve_choice!(target: bears) }.to change { p1.library.count }.by(-1)

    expect(rigging.exiled_cards).to include(bears)
    expect(game.exile).to include(bears)
    expect(p1.library.last(4)).to match_array(other_four)
  end

  context "with a card hidden away" do
    let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p1) }

    before do
      game.resolve_choice!(target: bears)
      go_to_main_phase!
    end

    it "puts a +1/+1 counter on a creature you control at the beginning of combat" do
      angel.trigger_effect(:add_counter, counter_type: "+1/+1", target: angel, amount: 0)
      current_turn.beginning_of_combat!

      expect(angel.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect(game.choices).to be_empty
    end

    it "only triggers on your turn" do
      go_to_main_phase_for!(p2)
      current_turn.beginning_of_combat!

      expect(angel.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
    end

    context "when you control a creature with power 7 or greater" do
      before do
        angel.trigger_effect(:add_counter, counter_type: "+1/+1", target: angel, amount: 1)
        game.tick!
      end

      it "may play the exiled card without paying its mana cost" do
        current_turn.beginning_of_combat!
        expect(game.choices.last).to be_a(described_class::PlayExiledCardChoice)

        game.resolve_choice!
        game.stack.resolve!

        expect(game.battlefield.creatures.by_name("Grizzly Bears").count).to eq(1)
        expect(rigging.exiled_cards).not_to include(bears)
      end

      it "leaves the card in exile if you decline" do
        current_turn.beginning_of_combat!
        game.skip_choice!

        expect(rigging.exiled_cards).to include(bears)
        expect(game.battlefield.creatures.by_name("Grizzly Bears")).to be_empty
      end
    end

    it "doesn't offer the exiled card when no creature has power 7 or greater" do
      current_turn.beginning_of_combat!

      expect(game.choices).to be_empty
    end
  end
end
