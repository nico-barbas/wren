#include "wren.h"

int main(void)
{
  WrenConfiguration config;
  wrenInitConfiguration(&config);

  WrenVM* vm = wrenNewVM(&config);
  if (vm == NULL) return 1;

  WrenInterpretResult result = wrenInterpret(vm, "main", "var answer = 6 * 7");
  if (result == WREN_RESULT_SUCCESS)
  {
    wrenEnsureSlots(vm, 1);
    wrenGetVariable(vm, "main", "answer", 0);
    if (wrenGetSlotDouble(vm, 0) != 42) result = WREN_RESULT_RUNTIME_ERROR;
  }

  wrenFreeVM(vm);
  return result == WREN_RESULT_SUCCESS ? 0 : 1;
}
