#pragma once
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
extern const int NON_FLAT;
extern const int NON_FLAT;
extern const int FLAT_CHILDREN;
extern const int FLAT_CHILDREN;
extern const int FLAT;
extern const int FLAT;
typedef struct datum datum;
#include <inttypes.h>
#include <stdio.h>
enum datum_type {
  DATUM_LIST,
  DATUM_SYMBOL,
  DATUM_BYTESTRING,
  DATUM_INTEGER,
};
typedef enum datum_type datum_type;
typedef struct array array;
struct array {
  datum *begin;
  size_t length;
};
struct datum {
  enum datum_type type;
  union {
    array list_value;
    char *symbol_value;
    char *bytestring_value;
    int64_t integer_value;
  };
};
datum datum_make_list_of_impl(size_t count,datum *values);
#define datum_make_list_of(...)                                                \
  datum_make_list_of_impl(sizeof((datum[]){__VA_ARGS__}) / sizeof(datum),      \
                          (datum[]){__VA_ARGS__})
typedef struct vec vec;
struct vec {
  array storage;
  size_t length;
};
vec vec_make_of_impl(size_t count,datum *values);
#define vec_make_of(...)                                                       \
  vec_make_of_impl(sizeof((datum[]){__VA_ARGS__}) / sizeof(datum),             \
                   (datum[]){__VA_ARGS__})
bool datum_is_symbol(datum *e);
bool datum_is_integer(datum *e);
bool datum_is_bytestring(datum *e);
datum datum_make_symbol(char *name);
datum datum_make_bytestring(char *text);
datum datum_make_int(int64_t value);
char *datum_repr(datum *e);
typedef struct extension extension;
typedef struct context context;
struct context {
  bool aborted;
  char error[1024];
};
struct extension {
  void (*call)(extension *self, vec *sl, datum *stmt, int *i, datum *compdata,
               context *ctxt);
};
char *datum_repr_pretty(datum *e,extension *ext);
bool datum_eq(datum *x,datum *y);
bool datum_is_constant(datum *d);
bool datum_is_the_symbol(datum *d,char *val);
array array_make_uninitialized(size_t length);
vec vec_make(size_t capacity);
datum list_make_copies(size_t length,datum val);
vec vec_make_copies(size_t length,datum val);
datum *vec_append(vec *s,datum x);
datum *vec_at(vec *s,size_t index);
size_t vec_length(vec *s);
datum datum_make_list(vec v);
datum datum_make_nil();
bool datum_is_list(datum *e);
bool datum_is_nil(datum *e);
size_t array_length(array *arr);
datum *array_at(array *arr,size_t i);
int list_length(datum *seq);
datum *list_at(datum *list,unsigned index);
datum list_copy(datum *list,int from,int to);
datum *list_get_last(datum *list);
datum list_get_tail(datum *list);
void vec_extend(vec *list,datum *another);
int list_index_of(datum *xs,datum *x);
datum datum_copy(datum *d);
vec vec_copy(vec *src);
vec list_to_vec(datum *val);
enum token_type {
  TOKEN_DATUM,
  TOKEN_RIGHT_PAREN,
  TOKEN_LEFT_PAREN,
  TOKEN_RIGHT_SQUARE,
  TOKEN_LEFT_SQUARE,
  TOKEN_RIGHT_CURLY,
  TOKEN_LEFT_CURLY,
  TOKEN_CONTROL_SEQUENCE,
  TOKEN_ERROR,
  TOKEN_EOF,
};
typedef enum token_type token_type;
typedef struct read_result read_result;
enum read_result_type {
  READ_RESULT_OK,
  READ_RESULT_EOF,
};
typedef enum read_result_type read_result_type;
struct read_result {
  enum read_result_type type;
  struct datum ok_value;
};
read_result datum_read_all(FILE *stre,context *ctxt);
datum datum_read_one(datum *args,context *ctxt);
bool read_result_is_ok(read_result x);
context *context_alloc_make();
char *context_abort_reason(context *ctxt);
void abortf(context *ctxt,char *format,...);
void prog_compile(vec *sl,datum *source,datum *compdata,extension *ext,context *ctxt);
void prog_append_bytecode(vec *sl,vec *src_sl);
ptrdiff_t *prog_define_routine(vec *sl,datum name,datum *compdata,context *ctxt);
ptrdiff_t *prog_append_jmp(vec *sl);
ptrdiff_t *prog_get_jmp_delta(vec *sl,size_t offset);
datum compdata_make();
datum *compdata_alloc_make();
datum compdata_get_polyindex(datum *compdata,datum *var);
vec vec_create_slice();
size_t prog_get_next_index(vec *sl);
typedef struct result result;
struct result {
  datum type;
  datum value;
};
result routine_run(vec *sl,datum *r,datum args,context *ctxt);
typedef struct routine routine;
datum routine_make(ptrdiff_t prg,routine *context);
datum *routine_make_alloc(ptrdiff_t prg,routine *context);
typedef struct lisp_extension lisp_extension;
struct lisp_extension {
  extension base;
  vec program;
  datum routine_;
  datum compdata;
  result (*runner)(vec *, datum *, datum, context *); 
};
lisp_extension lisp_extension_make(vec program,datum routine_,datum compdata,result(*runner)(vec *,datum *,datum,context *));
extension null_extension_make();
