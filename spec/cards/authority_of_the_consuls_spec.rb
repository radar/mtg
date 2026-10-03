# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AuthorityOfTheConsuls do
  include_context "two player game"

  # The Card() helper wants every word capitalised.
  let!(:authority) { ResolvePermanent("Authority Of The Consuls", owner: p1) }

  it "makes creatures your opponents control enter tapped" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(bears).to be_tapped
  end

  it "does not tap your own creatures as they enter" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    expect(bears).not_to be_tapped
  end

  it "does not tap the opponent's noncreature permanents" do
    land = ResolvePermanent("Forest", owner: p2)

    expect(land).not_to be_tapped
  end

  it "gains you 1 life whenever a creature an opponent controls enters" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(p1.life).to eq(22)
    expect(p2.life).to eq(20)
  end

  it "does not gain life when your own creature enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(p1.life).to eq(20)
  end

  it "does not gain life when an opponent's noncreature permanent enters" do
    ResolvePermanent("Forest", owner: p2)

    expect(p1.life).to eq(20)
  end

  it "stops applying when it leaves the battlefield" do
    authority.destroy!
    game.settle!
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(bears).not_to be_tapped
    expect(p1.life).to eq(20)
  end
end
