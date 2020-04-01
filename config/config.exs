use Mix.Config

config :pipelines, Pipelines,
  error_logger: Pipelines.SimpleLogger,
  step_error_handling: :throw,
  step_safe_error_message: "something went terribly wrong."
