# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LittleBear do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Large Bear", owner: p1) }
  let!(:other) { ResolvePermanent("Large Bear", owner: p1) }

  before do
    bear.tap!
    other.tap!
  end

  it "has flash" do
    expect(Card("Little Bear").flash?).to eq(true)
  end

  it "untaps another Bear and puts a +1/+1 counter on it" do
    ResolvePermanent("Little Bear", owner: p1)
    game.resolve_choice!(target: bear)
    expect(bear).not_to be_tapped
    expect(bear.power).to eq(6)
  end

  it "does not add a counter to a non-Bear" do
    elf = ResolvePermanent("Guardian Of The Halls", owner: p1)
    elf.tap!
    bear.destroy!
    other.destroy!
    ResolvePermanent("Little Bear", owner: p1)
    expect(elf).not_to be_tapped
    expect(elf.power).to eq(2)
  end
end
