module Magic
  module Tokens
    # A 1/1 black Rat creature token with "This token gets +1/+1 for each other Rat you control."
    VrenRat = Token.create("Rat") do
      creature_type "Rat"
      power 1
      toughness 1
      colors :black

      def static_abilities = [self.class::OtherRats]
    end

    VrenRat.const_set(:OtherRats, Class.new(Abilities::Static::PowerAndToughnessModification) do
      def applicable_targets = [source]

      def power_modification = other_rats

      def toughness_modification = other_rats

      def other_rats = (source.controller.creatures - [source]).count { _1.type?("Rat") }
    end)
  end
end
