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

  config.around(:each, type: :request, api_docs: true) do |example|
    example_group = example.metadata[:example_group]
    example_groups = []
    while example_group
      example_groups << example_group
      example_group = example_group[:example_group]
    end

    @level_3 = example_groups[-3][:description_args].first if example_groups[-3]
    @level_2 = example_groups[-2][:description_args].first if example_groups[-2]  
    @level_1 = example_groups[-1][:description_args].first 
    file_name = @level_1.underscore.gsub(/\s+/, '_')
    if defined? Rails
      @file = File.join(Rails.root, "/api_docs/#{file_name}.txt")
    else
      @file = File.join(File.expand_path('.'), "/api_docs/#{file_name}.txt")
    end 
    @action = example.description    
    example.run
  end

  config.after(:each, type: :request, api_docs: true) do
    break if response.nil? || response.status == 401 || response.status == 403 || response.status == 301

    File.open(@file, 'a') do |f|
      unless $header_written
        if @level_3
          f.write "# #{@level_1}\n\n"
          f.write "## Group #{@level_2}\n\n"
          f.write "### #{@level_3}\n\n"
        elsif @level_2
          f.write "# Group #{@level_1}\n\n"
          f.write "## #{@level_2}\n\n"
        else
          f.write "# #{@level_1}\n\n"
        end
        $header_written = true
      end

      action_level =  if @level_3
                        '####'
                      elsif @level_2
                        '###'
                      else
                        '##'
                      end
      f.write "#{action_level} #{@action}\n\n"

      # Request
      request_body = request.body.read
      if request_body.present? 
        f.write "+ Request (#{request.content_type})\n\n"
        # Request Body
        if request_body.present? && 'application/json' == request.content_type.to_s
          f.write "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(8)
        end
      end

      # Response
      f.write "+ Response #{response.status} (#{response.content_type})\n\n"
      # Response Headers
      f.write "+ Headers\n\n".indent(4)
        response.headers.each do |k,v| 
          next if /Content-Type/i === k
          f.write "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
        end
      # Response Body
      f.write "+ Body\n\n".indent(4)
      if response.body.present?
        if /application\/json/ === response.content_type.to_s
          f.write "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(12)
        else
          f.write "response.body".indent(12)
        end  
      end
    end
  end
end
