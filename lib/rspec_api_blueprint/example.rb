class Example

  def initialize(example)
    @example = example
  end

  attr_reader :example

  def levels
    @levels ||= example_groups.reverse.map{ |example_group| example_group[:description_args].first }.compact
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