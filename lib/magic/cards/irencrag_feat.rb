module Magic
  module Cards
    class IrencragFeat < Sorcery
      card_name "Irencrag Feat"
      cost generic: 1, red: 3

      def resolve!
        controller.add_mana(red: 7)
      end
    end
  end
end
