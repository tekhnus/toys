// a small library which wraps zlisp interpreter implementation
// so that it can be used from within zlisp itself.
#include <zlisp-impl/main.h>

fdatum_t read(datum_t *sptr) {
  if (!datum_is_pointer(sptr) || !datum_is_symbol(sptr->pointer_descriptor) ||
      strcmp(sptr->pointer_descriptor->symbol_value, "pointer")) {
    return fdatum_make_panic("read expects a pointer argument");
  }
  read_result_t r = datum_read(*(FILE **)sptr->pointer_value);
  if (read_result_is_eof(r)) {
    return fdatum_make_ok(datum_make_list_1(datum_make_symbol(":eof")));
  }
  if (!read_result_is_ok(r)) {
    char *err_message;
    if (read_result_is_panic(r)) {
      err_message = r.panic_message;
    } else {
      err_message = "unknown read error";
    }
    datum_t *err = datum_make_list_2(datum_make_symbol(":err"),
                                     datum_make_bytestring(err_message));
    return fdatum_make_ok(err);
  }
  datum_t *ok = datum_make_list_2(datum_make_symbol(":ok"), r.ok_value);
  return fdatum_make_ok(ok);
}

fdatum_t eval(datum_t *v, datum_t *nsp) {
  state_t *ns = *(state_t **)nsp->pointer_value;
  fstate_t r = datum_eval(v, ns, NULL);
  if (fstate_is_panic(r)) {
    return fdatum_make_ok(datum_make_list_2(
        datum_make_symbol(":err"), datum_make_bytestring(r.panic_message)));
  }
  fdatum_t val = state_stack_peek(r.ok_value);
  if (fdatum_is_panic(val)) {
    return fdatum_make_panic(val.panic_message);
  }
  void **new_nsp = malloc(sizeof(void **));
  *new_nsp = r.ok_value;
  return fdatum_make_ok(datum_make_list_3(datum_make_symbol(":ok"), val.ok_value,
                                       datum_make_pointer_to_pointer(new_nsp)));
}

fdatum_t prelude() {
  fstate_t prelude = fstate_make_prelude();
  if (fstate_is_panic(prelude)) {
    return fdatum_make_ok(
        datum_make_list_2(datum_make_symbol(":err"),
                          datum_make_bytestring(prelude.panic_message)));
  }
  void **prelude_p = malloc(sizeof(void **));
  *prelude_p = prelude.ok_value;
  return fdatum_make_ok(datum_make_list_2(
      datum_make_symbol(":ok"), datum_make_pointer_to_pointer(prelude_p)));
}
