module Magic
  module Cards
    class MutableExplorer < Creature
      card_name "Mutable Explorer"
      cost generic: 2, green: 1
      creature_type "Shapeshifter"
      power 1
      toughness 1
      keywords :changeling

      # "When this creature enters, create a tapped Mutavault token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Mutavault, enters_tapped: true)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
