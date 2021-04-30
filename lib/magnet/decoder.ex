defmodule Magnet.Decoder do
  @moduledoc """
  Decodes a Magnet URI to a `Magnet` struct.
  """

  def decode("magnet:?" <> magnet) do
    do_decode(magnet, [])
  end

  defp do_decode("", acc), do: acc

  defp do_decode(rest, acc) do
    with(
      {key, rest} <- do_decode_key(rest, []),
      {value, rest} <- do_decode_value(rest, []),
      do: do_decode(rest, [{key, value} | acc])
    )
  end

  defp do_decode_key(<<"=", rest::binary>>, acc) do
    result = convert_list_to_string(acc)
    {result, rest}
  end

  defp do_decode_key(<<char, rest::binary>>, acc) do
    do_decode_key(rest, [char | acc])
  end

  defp do_decode_value("", acc) do
    result = convert_list_to_string(acc)
    {result, ""}
  end

  defp do_decode_value(<<"&", rest::binary>>, acc) do
    result = convert_list_to_string(acc)
    {result, rest}
  end

  defp do_decode_value(<<char, rest::binary>>, acc) do
    do_decode_value(rest, [char | acc])
  end

  # turn char lists created by accumulating strings into utf8 strings
  defp convert_list_to_string(list) do
    list
    |> Enum.reverse()
    |> List.to_string()
  end
end
