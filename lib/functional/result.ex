defmodule Functional.Result do
  @type t :: { :ok, term() } | { :error, atom() | map() | String.t() }

  @spec map(t, (term() -> term())) :: t
  def map({ :error, _ } = value, _),
    do: value
  def map({:ok, value}, f),
    do: { :ok, f.(value) }
end
