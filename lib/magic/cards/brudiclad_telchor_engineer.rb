module Magic
  module Cards
    BrudicladTelchorEngineer = Creature("Brudiclad, Telchor Engineer") do
      cost generic: 4, blue: 1, red: 1
      type T::Super::Legendary, T::Artifact, T::Creature, *creature_types("Phyrexian Artificer")
      power 4
      toughness 4
    end

    class BrudicladTelchorEngineer < Creature
      MyrToken = Token.create "Phyrexian Myr" do
        artifact_creature_type "Phyrexian Myr"
        power 2
        toughness 1
        colors :blue
      end

      # "Creature tokens you control have haste."
      class TokensHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { source.controller.creatures.select(&:token?) }
      end

      # "Then you may choose a token you control. If you do, each other token you control becomes a copy of that token."
      class CopyChoice < Magic::Choice::Targeted
        def prompt = "Choose a token you control. Each other token you control becomes a copy of it."

        def targets? = false

        def choices = controller.permanents.select(&:token?)

        def choice_amount = 1

        def resolve!(target:)
          controller.permanents.select(&:token?).each do |token|
            next if token.equal?(target)

            token.copied_card = target.copiable_card
            token.apply_continuous_effects!
          end
        end
      end

      # "At the beginning of combat on your turn, create a 2/1 blue Phyrexian Myr artifact creature token. Then ..."
      class CombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          trigger_effect(:create_token, token_class: MyrToken)
          choice = CopyChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.size > 1
        end
      end

      def static_abilities = [TokensHaste]
      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
