module Magic
  # Amass <Type> N (rule 701.47): put N +1/+1 counters on an Army you control (it's also <Type>);
  # if you control no Army, first create a 0/0 black <Type> Army token.
  #
  #   Magic::Amass.call(source: actor, controller: controller, amount: 3)
  #
  # Returns the Army that got the counters (nil if it couldn't be found).
  module Amass
    @army_tokens = {}

    # One 0/0 black "<Type> Army" token class per creature type, built on first use.
    def self.army_token(subtype)
      @army_tokens[subtype] ||= Token.create "#{subtype} Army" do
        creature_type "#{subtype} Army"
        power 0
        toughness 0
        colors :black
      end
    end

    def self.call(source:, controller:, amount:, subtype: "Goblin")
      army = controller.creatures.by_type("Army").first
      army ||= create_army(source: source, controller: controller, subtype: subtype)
      return unless army

      army.add_types(subtype, until_eot: false) unless army.type?(subtype)
      source.trigger_effect(:add_counter, counter_type: "+1/+1", target: army, amount: amount)
      army
    end

    def self.create_army(source:, controller:, subtype:)
      created = source.create_token(token: army_token(subtype), controller: controller)
      Array(created).flatten.first
    end
  end
end
