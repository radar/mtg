module Magic
  module Cards
    SpringheartNantuko = Creature("Springheart Nantuko") do
      enchantment_creature_type("Insect Monk")
      cost generic: 1, green: 1
      bestow Costs::Mana.new(generic: 1, green: 1)
      power 1
      toughness 1
    end

    class SpringheartNantuko < Creature
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        power 1
        toughness 1
        colors :green
      end

      # "Enchanted creature gets +1/+1."
      def power_modification = 1

      def toughness_modification = 1

      # "You may pay {1}{G} if this permanent is attached to a creature you control. If you do, create a token that's a
      # copy of that creature. If you didn't create a token this way, create a 1/1 green Insect creature token."
      class CopyOrInsectChoice < Magic::Choice::PayMana
        attr_reader :host

        def initialize(host:, **args)
          @host = host
          super(**args)
        end

        def resolve!(**args)
          super
          copy_as_token(host.copiable_card)
        end

        def decline!
          super
          create_token(token: InsectToken, controller: controller)
        end
      end

      # "Landfall — Whenever a land you control enters, ..."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          host = actor.attached_to if actor.bestowed_now?
          host = nil unless host&.controller == controller
          choice = host && CopyOrInsectChoice.new(actor:, mana: { generic: 1, green: 1 }, host:)

          if choice&.can_pay?
            game.choices.add(choice)
          else
            create_token(token: InsectToken, controller: controller)
          end
        end
      end

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
