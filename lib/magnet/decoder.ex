defmodule Magnet.Decoder do
  @moduledoc """
  Decodes a Magnet URI to a `Magnet` struct.
  """

  @spec decode(String.t()) :: {:ok, Magnet.t()} | {:error, atom}
  def decode("magnet:?" <> magnet) do
    magnet =
      magnet
      |> do_decode([])
      |> Enum.into(%Magnet{})

    {:ok, magnet}
  end

  def decode(_), do: {:error, :invalid}

  @spec do_decode(String.t(), [{String.t(), String.t()}]) :: [{String.t(), String.t()}]
  defp do_decode("", acc), do: acc

  defp do_decode(rest, acc) do
    with {key, rest} <- do_decode_key(rest, []),
         {value, rest} <- do_decode_value(rest, []) do
      do_decode(rest, [{key, value} | acc])
    end
  end

  @spec do_decode_key(binary, charlist) :: {String.t(), String.t()}
  defp do_decode_key(<<"=", rest::binary>>, acc) do
    with result <- convert_list_to_string(acc), do: {result, rest}
  end

  defp do_decode_key(<<char, rest::binary>>, acc) do
    do_decode_key(rest, [char | acc])
  end

  @spec do_decode_value(binary, charlist) :: {String.t(), String.t()}
  defp do_decode_value("", acc) do
    with result <- convert_list_to_string(acc), do: {result, ""}
  end

  defp do_decode_value(<<"&", rest::binary>>, acc) do
    with result <- convert_list_to_string(acc), do: {result, rest}
  end

  defp do_decode_value(<<char, rest::binary>>, acc) do
    do_decode_value(rest, [char | acc])
  end

  # turn char lists created by accumulating strings into utf8 strings
  @spec convert_list_to_string(charlist) :: String.t()
  defp convert_list_to_string(list) do
    list
    |> Enum.reverse()
    |> List.to_string()
  end
end
