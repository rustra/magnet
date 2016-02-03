defmodule Magnet.EncoderTest do
  use ExUnit.Case

  alias Magnet.Encoder

  test "encoding empty magnet should result in `magnet:?`" do
    assert Encoder.encode(%Magnet{}) == "magnet:?"
  end

  test "should encode input and decode it back to the same" do
    magnet =
      ~w(magnet:?
         xl=10826029
         &dn=mediawiki-1.15.1.tar.gz
         &tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce
         &as=http%3A%2F%2Fdownload.wikimedia.org%2Fmediawiki%2F1.15%2Fmediawiki-1.15.1.tar.gz
         &xs=http%3A%2F%2Fcache.example.org%2FXRX2PEFXOOEJFRVUCX6HMZMKS5TWG4K5
         &xs=dchub://example.org
      ) |> Enum.join

    data = magnet |> Magnet.decode |> Enum.into(%Magnet{})

    assert data == (data |> Encoder.encode |> Magnet.decode |> Enum.into(%Magnet{}))
  end
end
