require "spec_helper"

RSpec.describe Magic::Cards::StingSlinger do
  include_context "two player game"

  let!(:slinger) { ResolvePermanent("Sting-Slinger", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def activate(blighting)
    p1.add_mana(red: 2)
    p1.activate_ability(ability: slinger.activated_abilities.first) do
      _1.pay_mana(generic: { red: 1 }, red: 1)
      _1.pay_blight(blighting)
    end
    game.stack.resolve!
  end

  it "is a 3/3" do
    expect([slinger.power, slinger.toughness]).to eq([3, 3])
  end

  it "deals 2 damage to each opponent for {1}{R}, {T}, and blighting 1" do
    activate(bears)

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(20)
    expect(slinger).to be_tapped
    expect(bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "can blight itself" do
    activate(slinger)

    expect(slinger.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(p2.life).to eq(18)
  end

  it "can't blight an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    expect { activate(theirs) }.to raise_error(/Invalid creature chosen to blight/)
  end
end
