defmodule Pipelines.Tokenizer do
  @moduledoc false

  @callback tokenize({:error, term}) :: {:error, term}
  @callback tokenize({:ok, term}) :: {:ok, term}
end
