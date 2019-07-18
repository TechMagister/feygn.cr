require "halite"

require "./annotations"

module Feygn
  VERSION = "0.1.0"

  # Make the (GET for now) call, and parse the response
  macro feygn_call(**options)
    {%
      request_line_ann = @def.annotation(RequestLine)
      headers_ann = @def.annotation(Headers)
      query_params_ann = @def.annotation(QueryParams)
      body_ann = @def.annotation(Body)

      should_parse_response = @def.return_type.id != "" &&
                              (options[:parse].class_name == "NilLiteral" || options[:parse])
      request_line_match = request_line_ann[0].split(' ')
      verb = request_line_match[0]
      url = request_line_match[1]
    %}

    # ----- Params -----
    {% if query_params_ann %}
      params = {{query_params_ann[0]}}
      {% for arg in @def.args %}
        params.each do |key, value|
          params[key] = value.gsub("{{{arg.name}}}", {{arg.name}})
        end
      {% end %}
    {% end %}

    # ----- Headers -----
    {% if headers_ann %}
    headers = {{headers_ann[0]}}
    {% end %}

    # ----- Body -----
    {% if body_ann %}
        {%
          body_param = body_ann[0]
          body_type = body_ann[:type]
        %}

        body_content = {{body_param.id}}
    {% end %}

    # ----- URL -----
    url = {{url}}

    {% for arg in @def.args %}
      url = url.gsub("{{{arg.name}}}", {{arg.name}})
    {% end %}

    # ----- Response -----
    response = @feygn_client.{{verb.downcase.id}}(
      url,
      {% if body_ann && body_type == "json" %}json: body_content,{% end %}
      {% if body_ann && body_type == "raw" %}raw: body_content,{% end %}
      {% if body_ann && body_type == "form" %}form: body_content,{% end %}
      {% if query_params_ann %}params: params,{% end %}
      {% if headers_ann %}headers: headers,{% end %}
    )

    # ----- Parse -----
    {% if should_parse_response %}
      {% if request_line_ann[:produces] == "application/json" %}
        {{@def.return_type.id}}.from_json(response.body)
      {% end %}
    {% end %}
  end

  # Instanciate the http client
  macro feygn_client
    {%
      ann = @type.annotation(FeygnClient)
      headers_ann = @type.annotation(Headers)
    %}
      @feygn_client = Halite::Client.new do
        {% if headers_ann %} headers_provided = {{headers_ann[0]}} {% end %}

        {% if ann[:endpoint] %} endpoint {{ann[:endpoint]}} {% end %}
        {% if headers_ann %} headers(headers_provided) {% end %}
        {% if ann[:cookies] %} cookies {{ann[:cookies]}} {% end %}
        {% if ann[:params] %} params {{ann[:params]}} {% end %}
        {% if ann[:form] %} form {{ann[:form]}} {% end %}
        {% if ann[:json] %} json {{ann[:json]}} {% end %}
        {% if ann[:raw] %} raw {{ann[:raw]}} {% end %}
        {% if ann[:timeout] %} timeout {{ann[:timeout]}} {% end %}
        {% if ann[:follow] %} follow {{ann[:follow]}} {% end %}
        {% if ann[:tls] %} tls {{ann[:tls]}} {% end %}

      end

      def client() : Halite::Client
        @feygn_client
      end
    end
end
