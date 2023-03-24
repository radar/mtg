require "spec_helper"

RSpec.describe Magic::Cards::ContainmentPriest do
  include_context "two player game"

  subject! { ResolvePermanent("Containment Priest", owner: p1) }
  # Containment Priest
  # # Capture Sphere {1}{U}{1}{W}
  # Creature -- Human Cleric
  # Flash (You may cast this spell any time you could cast an instant.)
  # Enchant creature

  context "base card atrributes" do
    it "is a human cleric" do
      expect(subject.card.type_line).to eq("Creature -- Human Cleric")
    end

    it "has flash" do
      expect(subject.flash?).to eq(true)
    end

    it "has a power + toughness" do
      expect(subject.power).to eq(2)
      expect(subject.toughness).to eq(2)
    end
  end
end
