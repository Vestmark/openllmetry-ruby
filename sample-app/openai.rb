require "openai"
require "traceloop/sdk"

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_API_KEY")
end

client = OpenAI::Client.new

# Example 1: No name suffix (backward compatible)
# Uses OTEL_SERVICE_NAME as-is, or defaults to "unknown_service:ruby"
traceloop = Traceloop::SDK::Traceloop.new

# Example 2: With name suffix
# If OTEL_SERVICE_NAME="my-app", this creates "worker-my-app"
# traceloop_worker = Traceloop::SDK::Traceloop.new(name: "worker")

# Example 3: Multiple instances
# traceloop_api = Traceloop::SDK::Traceloop.new(name: "api")
# traceloop_background = Traceloop::SDK::Traceloop.new(name: "background")

traceloop.workflow("joke_generator") do
  traceloop.llm_call(provider="openai", model="gpt-3.5-turbo") do |tracer|
    tracer.log_prompt(user_prompt="Tell me a joke about OpenTelemetry")
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Tell me a joke about OpenTelemetry" }]
      })
    tracer.log_response(response)
    puts response.dig("choices", 0, "message", "content")
  end
end
