module FactoryLite
  class Container
    attr_reader :config

    def initialize(config)
      @config = config
      @factories = {}
    end

    def register_factory(factory_name, attrs_key: factory_name, &block)
      @factories[factory_name] = Instance.new(attrs_key, config: config)
      instance_exec(@factories[factory_name], &block)
    end

    def extend_factory(original_factory, as:, &block)
      @factories[as] = factories(original_factory).extend(as)
      instance_exec(@factories[as], &block)
    end

    def create(factory_name, attrs = {})
      factories(factory_name).create(self, attrs)
    end

    def sequence(start = 0, &block)
      n = start
      proc do
        res = block[n]
        n += 1
        res
      end
    end

    private

    def factories(factory_name)
      @factories.fetch(factory_name) do
        raise "Unknown factory: #{factory_name}"
      end
    end
  end
end
