defmodule Pipelines.DSLTestCase do
  alias Pipelines.DSL
  use ExUnit.Case, async: true

  defmodule TestDSL.AddThreePipeline.AddOne do
    use Pipelines.Step

    def run(n), do: {:ok, n + 1}
  end

  defmodule TestDSL.AddThreePipeline.AddTwo do
    use Pipelines.Step

    def run(n), do: {:ok, n + 2}
  end

  defmodule TestDSL do
    use DSL

    defines_pipeline(:add_three,
      with: :i,
      steps: [
        :add_one,
        :add_two
      ]
    )
  end

  describe "define_pipeline/1" do
    test "creates compile time add_three/1" do
      assert TestDSL.add_three(1) == {:ok, 4}
    end
  end

  describe "compile_steps/3" do
    test "returns full modules from given list" do
      steps = DSL.compile_steps(TestDSL, "AddThree", [:add_one, :add_two])

      assert steps == [
               TestDSL.AddThreePipeline.AddOne,
               TestDSL.AddThreePipeline.AddTwo
             ]
    end

    test "raises StepError when given step does not resolve to a correct Module.call" do
      assert_raise Pipelines.StepError,
                   "Elixir.Pipelines.DSLTestCase.TestDSL.AddThreePipeline.Kaboom.call/1 is not defined",
                   fn ->
                     DSL.compile_steps(TestDSL, "AddThree", [:kaboom])
                   end
    end
  end

  describe "modulize_atom/1" do
    test "returns CamelizedVersionOfGivenAtom" do
      assert DSL.modulize_atom(:this_is_neat) == "ThisIsNeat"
    end
  end
end
