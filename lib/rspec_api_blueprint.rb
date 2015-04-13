require "rspec_api_blueprint/version"
require "rspec_api_blueprint/string_extensions"


RSpec.configure do |config|
  config.before(:suite) do
    if defined? Rails
      api_docs_folder_path = File.join(Rails.root, '/api_docs/')
    else
      api_docs_folder_path = File.join(File.expand_path('.'), '/api_docs/')
    end

    Dir.mkdir(api_docs_folder_path) unless Dir.exists?(api_docs_folder_path)

    Dir.glob(File.join(api_docs_folder_path, '*')).each do |f|
      File.delete(f)
    end
  end

  config.around(:each, type: :request) do |example|
    example_group = example.metadata[:example_group]
    example_groups = []

    while example_group
      example_groups << example_group
      example_group = example_group[:example_group]
    end

    @action = example_groups[-2][:description_args].first if example_groups[-2]
    @group_name = example_groups[-1][:description_args].first
    file_name = group_name.underscore
    if defined? Rails
      @file = File.join(Rails.root, "/api_docs/#{file_name}.txt")
    else
      @file = File.join(File.expand_path('.'), "/api_docs/#{file_name}.txt")
    end
    
    example.run
  end

  config.after(:each, type: :request) do
    return unless response.nil? || response.status == 401 || response.status == 403 || response.status == 301

    File.open(@file, 'a') do |f|
      f.write "# #{@group_name}"
      f.write "## #{@action}\n\n" if @action
        
      # Request
      request_body = request.body.read
      if request_body.present? 
        f.write "+ Request (#{request.content_type})\n\n"

        # Request Body
        if request_body.present? && 'application/json' == request.content_type.to_s
          f.write "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(authorization_header ? 12 : 8)
        end
      end

      # Response
      f.write "+ Response #{response.status} (#{response.content_type})\n\n"
      if response.body.present? && /application\/json/ === response.content_type.to_s
        f.write "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(8)
      end
    end
  end
end
