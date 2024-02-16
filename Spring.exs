defmodule Springs do
  def parse([]) do [] end
  def parse(string) do
    [first, second] = String.split(string)
    status = String.to_charlist(first)
    status = Enum.map(status, fn x -> if x === 63, do: :unk, else: x end)
    status = Enum.map(status, fn x -> if x === 46, do: :op, else: x end)
    status = Enum.map(status, fn x -> if x === 35, do: :dam, else: x end)
    pattern = ","
    numberlist = String.split(second, pattern)
    damaged = parse_num_to_str(numberlist)
    {status, damaged}
  end

  def parse_num_to_str([]) do [] end
  def parse_num_to_str([head|tail]) do
    [String.to_integer(head)|parse_num_to_str(tail)]
  end

  def multi_string(status, damaged_list, n) do
    # dup_status = String.duplicate(status <> "?", n)
    # final_status = String.slice(dup_status, 0, String.length(dup_status) - 1)
    spring_pattern = String.duplicate(status, n) <> " " <> String.duplicate(damaged_list <> ",", n)
    # spring_pattern = final_status <> " " <> String.duplicate(damaged_list <> ",", n)
    String.slice(spring_pattern, 0, String.length(spring_pattern) - 1)
  end

  # Handle the cases when the number of damaged springs is already 0.
  # Then, the spring after the last damaged spring must either be operational, unknown or empty
  def damaged([], 0) do
    {:ok, []}
  end
  def damaged([:dam | _], 0) do
    :nil
  end
  def damaged([ _ | rest], 0) do
    {:ok, rest}
  end

  # Handle the case when we have empty status, but the number of damaged springs is not 0.
  def damaged([], _) do
    :nil
  end
  # Handle the case when we have operational spring, but the number of damaged springs is not 0.
  def damaged([:op | _], _) do
    :nil
  end
  # Handle other cases, if it is unknown, it must be damaged.
  def damaged([_ | rest], n) do
    damaged(rest, n-1)
  end

  def solve({[], []}) do
    1
  end
  def solve({[], _}) do
    0
  end
  def solve({[:op | rest], []}) do
    solve({rest, []})
  end
  def solve({[:dam | _], []}) do
    0
  end
  def solve({[:unk | rest], []}) do
    solve({rest, []})
  end
  def solve({[ :op | status_rest], damaged}) do
    solve({status_rest, damaged})
  end

  def solve({[ :dam | status_rest], [n | damaged_rest]}) do
    case damaged(status_rest, n-1) do
      {:ok, status_rest} -> solve({status_rest, damaged_rest})
      :nil -> 0
    end
  end


  # ???...### 3,3
  # ###...###
  def solve({[ :unk | status_rest], [n | damaged_rest]}) do
    case damaged(status_rest, n-1) do
      # The unknown can either be damaged or operational.
      # If it is operational, we check the rest and keep the same number of damaged.
      # If it is damaged, we look at status after the consective damaged springs, and the rest of the damaged numbers.
      {:ok, damaged_status_rest} -> solve({status_rest, [n | damaged_rest]}) + solve({damaged_status_rest, damaged_rest})
      # The unknown can not be damaged, we know if it operational and check the rest.
      :nil -> solve({status_rest, [n | damaged_rest]})
    end
  end

  def solve_pattern(pattern) do
    solve(parse(pattern))
  end

  def bench(n) do
    Enum.map(1..n, fn i ->
      pattern = multi_string("????.######..#####.", "1,6,5", i)
      # pattern = multi_string("???.###", "1,1,3", i)
      {time, _} = :timer.tc(Springs, :solve_pattern, [pattern])
      IO.inspect(time)
    end)
    :ok
  end

end
"""
# fib(10)
# (fib(9) + fib(8))
# ((fib(8) + fib(7)) + fib(8))
# ((fib(8) + fib(7)) + fib(8))
def fib(0, _) do
  1
end
def fib(1, _) do
  1
end
def fib(n, mem) do
  case mem[n-1] do
    :nil -> case mem[n-2] do
      :nil ->
        result = fib(n-1, mem) + fib(n-2, mem)
        mem[n] = result
        result
      fib_
    end
    :nil ->
  end
  fib(n-1)+fib(n-2)
end
"""
