require "halite"

require "./annotations"

module Feygn
  VERSION = "0.1.0"

  # Make the (GET for now) call, and parse the response
  macro feygn_call(**options)
    {% feygn_ann = @def.annotation(GetMapping) %}
    {% should_parse_response = @def.return_type.id != "" && (options[:parse].class_name == "NilLiteral" || options[:parse]) %}

    params = {{feygn_ann[:params]}}
    headers = {{feygn_ann[:headers]}}
    url = {{feygn_ann[0]}}

    {% for arg in @def.args %}
      url = url.gsub("{{{arg.name}}}", {{arg.name}})
    {% end %}

    response = @feygn_client.get(url, params: params, headers: headers)

    {% if should_parse_response %}
      {% if feygn_ann[:produces] == "application/json" %}
        {{@def.return_type.id}}.from_json(response.body)
      {% end %}
    {% end %}
  end

  # Instanciate the http client
  macro feygn_client
    {% feygn_client_ann = @type.annotation(FeygnClient) %}
      @feygn_client = Halite::Client.new do
        # define endpoint
        {% if feygn_client_ann[:url].class_name != "NilLiteral" %}
        endpoint {{feygn_client_ann[:url]}}
        {% end %}

        # Enable logging
        logging true

        # Set timeout
        timeout 10.seconds
      end
    end
end
