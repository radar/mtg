require "spec_helper"

RSpec.describe "Indestructible" do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:taunter) { ResolvePermanent("Brash Taunter", owner: p2) }

  it "is not destroyed by a destroy effect" do
    bears.trigger_effect(:destroy_target, target: taunter)

    expect(taunter.zone).not_to be_nil
  end

  it "still lets a destroy effect destroy other creatures" do
    taunter.trigger_effect(:destroy_target, target: bears)

    expect(bears.zone).to be_nil
    expect(bears.card.zone).to eq(p1.graveyard)
  end

  it "does not stop a sacrifice" do
    taunter.sacrifice!

    expect(taunter.zone).to be_nil
    expect(taunter.card.zone).to eq(p2.graveyard)
  end

  it "does not stop being put into the graveyard directly" do
    taunter.put_into_graveyard!

    expect(taunter.zone).to be_nil
  end

  it "reports whether #destroy! destroyed anything" do
    expect(taunter.destroy!).to eq(false)
    expect(bears.destroy!).to eq(true)
  end
end
