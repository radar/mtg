module Magic
  module Cards
    Electroduplicate = Sorcery("Electroduplicate") do
      cost generic: 2, red: 1
      flashback Costs::Mana.new(generic: 2, red: 2)
    end

    class Electroduplicate < Sorcery
      class SacrificeTokenTrigger < TriggeredAbility::BeginningOfEndStep
        def call = actor.sacrifice!
      end

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        copy = Permanent.resolve(game: game, owner: controller, card: target.copiable_card, token: true, copy: true, cast: false)
        copy.grant_haste!
        copy.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTokenTrigger)
      end
    end
  end
end
