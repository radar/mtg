# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OmnivorousFlytrap do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def fill_graveyard(names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  let(:four_types) { ["Wood Elves", "Sol Ring", "Glorious Anthem", "Island"] }
  let(:six_types) { four_types + ["Lightning Bolt", "Crash Through"] }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  before { go_to_main_phase! }

  def enter_flytrap
    ResolvePermanent("Omnivorous Flytrap", owner: p1)
    game.settle!
  end

  it "is a 2/4 Plant" do
    flytrap = ResolvePermanent("Omnivorous Flytrap", owner: p1)
    expect(flytrap.power).to eq(2)
    expect(flytrap.toughness).to eq(4)
  end

  it "does nothing when it enters without delirium" do
    enter_flytrap
    expect(game.choices).to be_empty
    expect(counters(bear)).to eq(0)
  end

  it "distributes two counters when it enters with delirium" do
    fill_graveyard(four_types)
    enter_flytrap
    game.resolve_choice!(distribution: { bear => 2 })
    expect(counters(bear)).to eq(2)
  end

  it "doubles the counters with six card types" do
    fill_graveyard(six_types)
    enter_flytrap
    game.resolve_choice!(distribution: { bear => 2 })
    expect(counters(bear)).to eq(4)
  end

  it "triggers when it attacks with delirium" do
    flytrap = ResolvePermanent("Omnivorous Flytrap", owner: p1)
    game.settle!
    fill_graveyard(four_types)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: flytrap, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.resolve_choice!(distribution: { bear => 1, flytrap => 1 })
    expect(counters(bear)).to eq(1)
    expect(counters(flytrap)).to eq(1)
  end
end
