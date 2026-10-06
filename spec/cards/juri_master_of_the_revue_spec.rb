require 'spec_helper'

RSpec.describe Magic::Cards::JuriMasterOfTheRevue do
  include_context "two player game"

  let!(:juri) { ResolvePermanent("Juri, Master Of The Revue", owner: p1) }

  it "gets a +1/+1 counter when you sacrifice a permanent" do
    ResolvePermanent("Forest", owner: p1).sacrifice!
    game.settle!

    expect(juri.power).to eq(2)
  end

  it "deals damage equal to its power to any target when it dies" do
    juri.destroy!
    game.settle!

    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(19)
  end
end
