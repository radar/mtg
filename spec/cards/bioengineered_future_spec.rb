require "spec_helper"

RSpec.describe Magic::Cards::BioengineeredFuture do
  include_context "two player game"

  it "creates a Lander token when it enters" do
    ResolvePermanent("Bioengineered Future", owner: p1)

    expect(p1.permanents.by_name("Lander").count).to eq(1)
  end

  it "gives creatures counters based on lands that entered this turn" do
    ResolvePermanent("Bioengineered Future", owner: p1)
    ResolvePermanent("Forest", owner: p1)
    creature = ResolvePermanent("Grizzly Bears", owner: p1)

    expect(creature.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end
end