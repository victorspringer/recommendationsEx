defmodule UtilsTest do
    use ExUnit.Case, async: true
    use Plug.Test
    alias ZionRecs.Utils

    test 'encode_params' do
        params = %{
            :teste => "teste",
            "teste2" => "teste2"
        }
        
        response = params |> Utils.encode_params

        assert response == "teste: \"teste\", teste2: \"teste2\""
    end
end