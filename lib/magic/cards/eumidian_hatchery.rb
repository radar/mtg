module Magic
  module Cards
    EumidianHatchery = Card("Eumidian Hatchery") do
      type "Land"
    end

    class EumidianHatchery < Card
      class ManaAbility < Magic::TapManaAbility
        choices :black

        def resolve!
          controller.lose_life(1)
          source.add_counter("hatchling")
          super
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end