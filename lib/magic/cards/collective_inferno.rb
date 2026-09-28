module Magic
  module Cards
    CollectiveInferno = Enchantment("Collective Inferno") do
      cost generic: 3, red: 2
      convoke
    end

    class CollectiveInferno < Enchantment
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      # Double all damage that sources you control of the chosen type would deal.
      def replacement_effects = ReplacementEffect::ChosenTypeDamageDoubler.registrations
    end
  end
end
