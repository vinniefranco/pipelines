defmodule Pipelines do
  @moduledoc """
  Provides a way to chain units of work into a pipeline
  """

  @type context :: {:ok | :error, term}
  @type option ::
          {:error_approach, :throw | :safe}
          | {:error_logger, Pipelines.ErrorLogger.t()}
          | {:step_exception_message, String.t()}
  @type options :: [option]

  @spec run([Pipelines.Step.t(), ...], opts :: options) :: (... -> context)
  def run(steps, opts \\ []) do
    opts = Keyword.merge(Application.get_env(:pipelines, __MODULE__), opts)

    fn val ->
      Enum.reduce(steps, {:ok, val}, & &1.call(&2, opts))
    end
  end
end
