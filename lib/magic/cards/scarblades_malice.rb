module Magic
  module Cards
    class ScarbladesMalice < Instant
      card_name "Scarblade's Malice"
      cost black: 1

      ElfToken = Token.create "Elf" do
        creature_type "Elf"
        power 2
        toughness 2
        colors :black, :green
      end

      def target_choices = battlefield.controlled_by(controller).creatures

      # "When that creature dies this turn, create a 2/2 black and green Elf creature token."
      class DiesTrigger < TriggeredAbility
        def should_perform? = this?

        def call
          trigger_effect(:create_token, token_class: ElfToken, controller: actor.controller)
        end
      end

      # "Target creature you control gains deathtouch and lifelink until end of turn. When that
      # creature dies this turn, create a 2/2 black and green Elf creature token."
      def resolve!(target:)
        trigger_effect(:grant_keyword, target:, keyword: :deathtouch)
        trigger_effect(:grant_keyword, target:, keyword: :lifelink)
        target.register_turn_trigger(Events::CreatureDied, DiesTrigger)
      end
    end
  end
end
