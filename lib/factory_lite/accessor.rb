module FactoryLite
  class Accessor
    def self.find(accessor)
      if accessor.respond_to?(:call)
        accessor
      else
        DEFAULT_ACCESSORS.fetch(accessor) do
          raise RuntimeError, "Unknown accessor type: #{accessor}"
        end
      end
    end

    DEFAULT_ACCESSORS = {
      none: ->(model) { model },
      trailblazer2: ->(result) { result["model"] },
      trailblazer1: ->(operation) { operation.model }
    }.freeze
  end
end
