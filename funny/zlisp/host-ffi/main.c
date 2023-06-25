// a basic CLI for zlisp interpreter.
#include <assert.h>
#include <main.h>

int main(int argc, char **argv) {
  context ctxt = {};
  if (argc != 2) {
    printf("usage: %s <file>\n", argv[0]);
    return (EXIT_FAILURE);
  }
  char *filename = argv[1];
  FILE *f = fopen(filename, "r");
  if (f == NULL) {
    perror("while opening file (C host)");
    return EXIT_FAILURE;
  }
  read_result rr = datum_read_all(f, &ctxt);
  fclose(f);
  if (ctxt.aborted) {
    fprintf(stderr, "%s", ctxt.error);
    return EXIT_FAILURE;
  }
  assert(read_result_is_ok(rr));
  assert(datum_is_list(&rr.ok_value));
  assert(list_length(&rr.ok_value) == 1);
  vec sl = list_to_vec(list_at(&rr.ok_value, 0));
  datum s = routine_make(0, NULL); // running starts from the first instruction.
  result res = host_ffi_run(&sl, &s, datum_make_nil(), &ctxt);
  if (ctxt.aborted) {
    fprintf(stderr, "%s", ctxt.error);
    return EXIT_FAILURE;
  }
  if (!datum_is_the_symbol(&res.type, "halt")) {
    fprintf(stderr, "runtime error: %s %s\n", datum_repr(&res.type),
            datum_repr(&res.value));
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
