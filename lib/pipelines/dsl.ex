defmodule Pipelines.DSL do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Pipelines.DSL
    end
  end

  defmacro defines_pipeline(name, opts) do
    namespace = modulize_atom(name)

    quote bind_quoted: [namespace: namespace, name: name, opts: opts] do
      param = Macro.var(opts[:with], __MODULE__)

      def unquote(name)(unquote(param)) do
        steps =
          compile_steps(
            __MODULE__,
            unquote(namespace),
            unquote(opts[:steps])
          )

        Pipelines.run(steps).(unquote(param))
      end
    end
  end

  def compile_steps(module, namespace, steps) do
    Enum.map(steps, fn step ->
      step_module =
        Module.concat(
          module,
          "#{namespace}Pipeline.#{modulize_atom(step)}"
        )

      unless function_exported?(step_module, :call, 1) do
        raise Pipelines.StepError, message: "#{step_module}.call/1 is not defined"
      end

      step_module
    end)
  end

  def modulize_atom(str) do
    str
    |> Atom.to_string()
    |> Macro.camelize()
  end
end
