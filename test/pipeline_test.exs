defmodule PipelinesTestCase do
  use ExUnit.Case, async: true

  alias Pipelines

  defmodule AddOne do
    use Pipelines.Step

    def run(n), do: {:ok, n + 1}
  end

  defmodule ErrorStep do
    use Pipelines.Step

    def run(message), do: {:error, "error: #{message}"}
  end

  defmodule FatalStep do
    use Pipelines.Step

    def run(_), do: raise("BOOM!")
  end

  defmodule Tokenizer do
    @behaviour Pipelines.Tokenizer

    @impl true
    def tokenize({:error, _term} = error) do
      error
    end

    @impl true
    def tokenize({:ok, value}), do: {:ok, "#{value} transformed"}
  end

  defmodule ValidationStep do
    use Pipelines.Step, type: :validator, tokenizer: Tokenizer

    def run(_), do: {:ok, "wooo"}
  end

  describe "validation step" do
    test "returns result formatted by given tokenizer" do
      assert ValidationStep.call({:ok, ''}) == {:ok, "wooo transformed"}
    end
  end

  describe "call/3" do
    test "returns {:error, val} when run/1 results in error" do
      assert ErrorStep.call({:ok, "tio"}) == {:error, "error: tio"}
    end

    @tag capture_log: true
    test "returns {:fatal, message} when contract is broken" do
      assert AddOne.call("waffle") == {
               :error,
               ~s(expected {:ok|:error, term} received "waffle")
             }
    end

    test "returns result of AddOne.run/1" do
      assert AddOne.call({:ok, 1}) == {:ok, 2}
    end
  end

  describe "run/1" do
    test "allows you to build a pipeline of arbitrary steps" do
      steps = [
        AddOne,
        AddOne
      ]

      chain = Pipelines.run(steps)

      assert chain.(1) == {:ok, 3}
    end

    @tag capture_log: true
    test "returns {:fatal, :safe_message} when a step raises an error" do
      steps = [
        FatalStep,
        AddOne
      ]

      chain =
        Pipelines.run(
          steps,
          step_error_handling: :safe,
          step_safe_error_message: "doh!"
        )

      assert chain.(1) == {:error, "doh!"}
    end
  end
end
