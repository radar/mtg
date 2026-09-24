require "spec_helper"

RSpec.describe Magic::Cards::TributaryVaulter do
  include_context "two player game"

  let!(:vaulter) { ResolvePermanent("Tributary Vaulter", owner: p1) }

  it "is a 1/3 flyer" do
    expect([vaulter.power, vaulter.toughness]).to eq([1, 3])
    expect(vaulter).to be_flying
  end

  it "gives another target Merfolk you control +2/+0 whenever it becomes tapped" do
    other = ResolvePermanent("Pestered Wellguard", owner: p1)
    vaulter.tap!
    game.settle!

    expect(other.power).to eq(5)
    expect(vaulter.power).to eq(1)
  end

  it "does nothing with no other Merfolk to target" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    vaulter.tap!
    game.settle!

    expect(game.choices).to be_empty
  end
end
