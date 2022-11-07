defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write!("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}

    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
    |> List.delete_at(length(hex)-1)
    |> Enum.chunk_every(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  filter_odd_squares takes a list of tuples from the Identicon struct and removes any that have a first value that is odd.

    ## Examples
      iex> Identicon.filter_odd_squares(%Identicon.Image{grid: [{3, 0}, {4,1}]})
      %Identicon.Image{grid: [{4,1}]}

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
   grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  pick_color takes a hashed input and returns an image struct.

    ## Example
      iex> Identicon.pick_color( %Identicon.Image{hex: [176, 104, 147, 28, 196, 80, 68, 43, 99, 245, 179, 210, 118, 234, 66, 151]})
      %Identicon.Image{hex: [176, 104, 147, 28, 196, 80, 68, 43, 99, 245, 179, 210, 118, 234, 66, 151],color: {176, 104, 147}}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail] } = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  mirror_row adds the reverse to the end of an array.

    ## Examples

      iex> Identicon.mirror_row([1,2,3])
      [1,2,3,2,1]

  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
  hash_input takes a string and turns it into a hash using the md5 algorithm.
  ## Examples

    iex> Identicon.hash_input("name")
    %Identicon.Image{hex: [176, 104, 147, 28, 196, 80, 68, 43, 99, 245, 179, 210, 118, 234, 66, 151]}

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end
end
