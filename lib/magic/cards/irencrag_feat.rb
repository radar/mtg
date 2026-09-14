module Magic
  module Cards
    class IrencragFeat < Sorcery
      card_name "Irencrag Feat"
      cost generic: 1, red: 3

      def resolve!
        controller.add_mana(red: 7)
        controller.limit_spells_this_turn!(1)
      end
    end
  end
end
