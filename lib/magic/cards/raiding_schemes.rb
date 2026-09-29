module Magic
  module Cards
    class RaidingSchemes < Enchantment
      card_name "Raiding Schemes"
      cost generic: 3, red: 1, green: 1

      # "Each noncreature spell you cast has conspire."
      class GrantConspire < StaticAbility
        def grants_conspire?(card, player)
          !card.creature? && player == controller
        end
      end

      def static_abilities = [GrantConspire]
    end
  end
end
