defmodule Pipelines.Step do
  @moduledoc false

  @callback run(payload :: term()) :: {:ok | :error, term()}

  defmacro __using__(step_opts) do
    quote do
      import Pipelines.Step,
        only: [
          handle_event: 3,
          handle_exception: 3,
          step_error_handling: 1,
          step_exception_message: 1
        ]

      @behaviour unquote(__MODULE__)
      @error_name "STEP_ERROR"

      @type context :: {:ok | :error, term()}
      @type option ::
              {:error_approach, :throw | :safe}
              | {:error_logger, Pipelines.ErrorLogger.t()}
              | {:step_exception_message, String.t()}
      @type options :: [option]

      @spec call(payload :: context, config_opts :: options) :: context
      def call(payload, config_opts \\ []) do
        case payload do
          {:ok, value} ->
            process_step(value, config_opts)

          {:error, _} = error ->
            error

          other ->
            error = "expected {:ok|:error, term} received #{inspect(payload)}"
            handle_event(@error_name, error, config_opts)
            {:error, error}
        end
      end

      @spec process_step(payload :: context, error_opts :: options) :: context
      defp process_step(payload, error_opts) do
        try do
          step_opts = unquote(step_opts)
          call_run(payload, Keyword.get(step_opts, :type, :default), step_opts)
        rescue
          error ->
            case step_error_handling(error_opts) do
              :throw ->
                throw(error)

              :safe ->
                handle_error_safely(error, __STACKTRACE__, error_opts)

              _ ->
                handle_error_safely(error, __STACKTRACE__, error_opts)
            end
        end
      end

      defp call_run(value, :default, _opts) do
        run(value)
      end

      defp call_run(value, :validator, opts) do
        value |> run() |> opts[:tokenizer].tokenize()
      end

      defp handle_error_safely(error, stacktrace, opts) do
        handle_exception(error, stacktrace, opts)

        # Don't reveal the entire error to the consumer of the pipeline.
        # This prevents end users from seeing error messages like:
        # {
        #   "error": {
        #     "__exception__": true,
        #     "args": null,
        #     "arity": 1,
        #     "clauses": null,
        #     "function": "has_conflicting_shares",
        #     "kind": null,
        #     "module": "Elixir.Insights.Guests"
        #   }
        # }"
        #
        # Which ain't gud.
        {:error, step_exception_message(opts)}
      end
    end
  end

  @type option ::
          {:step_error_handling, :throw | :safe}
          | {:error_logger, Pipelines.ErrorLogger.t()}
          | {:step_safe_error_message, String.t()}
  @type options :: [option]

  @spec handle_event(name :: String.t(), error :: term(), opts :: options) :: term()
  def handle_event(name, error, opts) do
    env(:error_logger, opts).handle_event(name, error)
  end

  @spec handle_event(error :: String.t(), stacktrace :: term(), opts :: options) :: term()
  def handle_exception(error, stacktrace, opts) do
    env(:error_logger, opts).handle_exception(error, stacktrace)
  end

  @spec step_exception_message(opts :: options) :: term()
  def step_exception_message(opts) do
    env(:step_safe_error_message, opts)
  end

  @spec step_error_handling(opts :: options) :: :safe | :throw
  def step_error_handling(opts) do
    env(:step_error_handling, opts)
  end

  defp env(key, opts) do
    :pipelines
    |> Application.get_env(Pipelines)
    |> Keyword.merge(opts)
    |> Keyword.get(key)
  end
end
