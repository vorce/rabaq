defmodule RabaqOutputterTest do
  use ExUnit.Case

  setup do
    File.mkdir_p(Path.join("test", "out_tmp"))
  end

  teardown do
    File.rm_rf(Path.join("test", "out_tmp"))
  end

  test "should init with correct arguments" do
    assert Rabaq.Outputter.init([1, Path.join("test", "out_tmp")]) ==
      {:ok, Rabaq.Outputter.OutputterState.new.max(1).outdir(
        Path.join("test", "out_tmp"))}
  end

  test "should set file in state" do
    state = Rabaq.Outputter.OutputterState.new.max(1).outdir(
      Path.join("test", "out_tmp"))
    assert Rabaq.Outputter.handle_file(state).file != nil
  end

  test "should close file" do
    state = Rabaq.Outputter.OutputterState.new.max(1).outdir(
      Path.join("test", "out_tmp")).count(0)
      |> Rabaq.Outputter.handle_file

    assert state.file != nil
    assert Rabaq.Outputter.terminate("reason", state) == :ok
    assert catch_error(IO.write(state.file, "irrelevant")) == :terminated
  end
end
