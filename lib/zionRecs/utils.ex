defmodule ZionRecs.Utils do
  
  def encode_params(params) do
    Enum.map(params, fn({key, val}) ->
      "#{key}: \"#{val}\""
    end) |> Enum.join(", ")
  end
end