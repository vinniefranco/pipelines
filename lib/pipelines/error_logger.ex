defmodule Pipelines.ErrorLogger do
  @moduledoc false

  @callback handle_event(name :: String.t(), payload :: term()) :: any()
  @callback handle_exception(name :: String.t(), stacktrace :: term()) :: any()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end
end

defmodule Pipelines.SimpleLogger do
  @moduledoc false

  require Logger
  use Pipelines.ErrorLogger

  def handle_event(name, payload) do
    Logger.warn("#{name}: #{inspect(payload)}")
  end

  def handle_exception(error, stacktrace) do
    Logger.error("EXCEPTION: #{Exception.format(:error, error, stacktrace)}")
  end
end
