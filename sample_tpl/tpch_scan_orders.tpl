struct State {
  sum: RealSumAggregate
}

fun setUpState(execCtx: *ExecutionContext, state: *State) -> nil {
  @aggInit(&state.sum)
}

fun teardownState(execCtx: *ExecutionContext, state: *State) -> nil {
}

struct outputStruct {
 c0 : Integer
}

fun execQuery(execCtx: *ExecutionContext, state: *State) -> nil {
  @execCtxStartResourceTracker(execCtx, 3)
  // Pipeline 1 (hashing)
  var tvi: TableVectorIterator
  var oids : [1]uint32
  oids[0] = 1
  @tableIterInitBind(&tvi, execCtx, "orders", oids)
  for (@tableIterAdvance(&tvi)) {
    var pci = @tableIterGetPCI(&tvi)
    for (; @pciHasNext(pci); @pciAdvance(pci)) {
      var out = @ptrCast(*outputStruct, @outputAlloc(execCtx))
      out.c0 = @pciGetInt(pci, 0)
    }
  }

  @outputFinalize(execCtx)
  @tableIterClose(&tvi)
  @execCtxEndResourceTracker(execCtx, @getParamString(execCtx, 0))
}

fun main(execCtx: *ExecutionContext) -> int32 {
  var state: State
  setUpState(execCtx, &state)
  execQuery(execCtx, &state)
  teardownState(execCtx, &state)
  return 37
}
