class Example

  def initialize(example)
    @example = example
  end

  attr_reader :example

  def levels
    @levels ||= (1..4).map{ |i| example_groups[-1*i][:description_args].first if example_groups[-1*i] }.compact
  end

  def example_description
    example.description
  end

  def headers
    example.metadata[:headers]
  end

  private

  def example_groups
    @example_groups ||= Array.new.tap do |example_groups|
      example_group = example.metadata[:example_group]
      while example_group
        example_groups << example_group
        example_group = example_group[:example_group]
      end
    end
  end
end