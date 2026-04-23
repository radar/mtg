# frozen_string_literal: true

module Magic
  module ResolvesWithArgs
    private

    # Call receiver.resolve! passing only the keyword arguments its signature accepts.
    # Callers supply the full pool of available values; this method filters to what
    # the method actually declares (both required and optional keywords).
    def resolve_with_args(receiver, **available)
      resolver = receiver.method(:resolve!)
      args = available.select do |key, _|
        resolver.parameters.include?([:keyreq, key]) ||
          resolver.parameters.include?([:key, key])
      end
      resolver.call(**args)
    end
  end
end
