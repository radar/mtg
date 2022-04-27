module Magic
  module Cards
    RunedHalo = Enchantment("Runed Halo") do
      cost white: 2
    end

    class RunedHalo < Enchantment
      def entered_the_battlefield!
        add_effect(
          "ChooseACard",
        )

        super
      end
    end
  end
end
