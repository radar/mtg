require "spec_helper"

RSpec.describe Magic::Cards::AzusasManyJourneys do
  include_context "two player game"

  it "enters with a lore counter" do
    saga = ResolvePermanent("Azusa's Many Journeys", owner: p1)

    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end

  it "has Likeness of the Seeker as its transformed face" do
    expect(Magic::Cards::LikenessOfTheSeeker::NAME).to eq("Likeness of the Seeker")
  end

  it "transforms the same permanent into its back face" do
    saga = ResolvePermanent("Azusa's Many Journeys", owner: p1)
    described_class::Chapter3.new(actor: saga).resolve!

    expect(saga.name).to eq("Likeness of the Seeker")
    expect(saga.token?).to be(false)
    expect(saga.card).to be_a(Magic::Cards::LikenessOfTheSeeker)
  end

  it "untaps up to three lands when Likeness becomes blocked" do
    likeness = ResolvePermanent("Likeness of The Seeker", owner: p1)
    lands = 3.times.map { ResolvePermanent("Forest", owner: p1) }
    lands.each(&:tap!)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: likeness, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: likeness)

    expect(lands).to all(be_untapped)
  end
end