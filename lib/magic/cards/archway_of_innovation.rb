module Magic
  module Cards
    ArchwayOfInnovation = Card("Archway of Innovation") do
      type "Land"
    end

    class ArchwayOfInnovation < Card
      # "This land enters tapped unless you control an Island."
      def enters_tapped? = controller.permanents.by_any_type("Island").none?

      # "{T}: Add {U}."
      class ManaAbility < Magic::TapManaAbility
        choices :blue
      end

      # "{U}, {T}: The next spell you cast this turn has improvise."
      class ImproviseAbility < Magic::ActivatedAbility
        costs "{U}, {T}"

        def resolve!
          controller.grant_next_spell_improvise!
        end
      end

      def activated_abilities = [ManaAbility, ImproviseAbility]
    end
  end
end
