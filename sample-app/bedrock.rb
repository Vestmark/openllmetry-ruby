require 'aws-sdk-bedrockruntime'
require "traceloop/sdk"

# Example 1: No name parameter (backward compatible)
# Uses OTEL_SERVICE_NAME as-is, or defaults to "unknown_service:ruby"
traceloop = Traceloop::SDK::Traceloop.new

# Example 2: With name parameter
# Creates service name as "#{name}-#{OTEL_ENVIRONMENT}"
# If OTEL_ENVIRONMENT="production", this creates "bedrock-worker-production"
# traceloop = Traceloop::SDK::Traceloop.new(name: "bedrock-worker")

model = "anthropic.claude-3-sonnet-20240229-v1:0"

traceloop.llm_call(provider="bedrock", model=model) do |tracer|
  tracer.log_prompt(user_prompt="Tell me a joke about OpenTelemetry")
  response = Aws::BedrockRuntime::Client.new.invoke_model({
      model_id: model,
      content_type: "application/json",
      accept: "*/*",
      body: {
        messages: [{ role: "user", content: "Tell me a joke about OpenTelemetry" }],
        max_tokens: 4096,
        anthropic_version: "bedrock-2023-05-31"
      }.to_json
    })
  tracer.log_response(response)

  body = JSON.parse(response.body.read())
  puts body
end
