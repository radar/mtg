# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodSeeker do
  include_context "two player game"

  let!(:seeker) { ResolvePermanent("Blood Seeker", owner: p1) }

  it "lets you make an opponent lose 1 life when their creature enters" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.resolve_choice!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "lets you decline" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.skip_choice!
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "ignores your own creatures" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(game.choices).to be_empty
  end

  it "ignores an opponent's non-creature permanents" do
    ResolvePermanent("Forest", owner: p2)

    expect(game.choices).to be_empty
  end
end
