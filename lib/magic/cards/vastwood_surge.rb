module Magic
  module Cards
    VastwoodSurge = Sorcery("Vastwood Surge") do
      cost generic: 3, green: 1
      kicker_cost generic: 4
    end

    class VastwoodSurge < Sorcery
      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 2, filter: Filter[:basic_lands])
        end

        def resolve!(targets:)
          targets.each { |target| target.resolve!(enters_tapped: true) }
          controller.shuffle!

          if actor.kicker_cost.paid?
            controller.creatures.each { |creature| creature.add_counter("+1/+1", amount: 2) }
          end
        end
      end

      def resolve!
        game.choices.add(VastwoodSurge::Choice.new(actor: self))
      end
    end
  end
end
