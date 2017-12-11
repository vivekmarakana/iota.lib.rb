#include <ruby.h>
#include <stdint.h>

#define HASH_LENGTH 243
#define NUMBER_OF_ROUNDS 81
#define STATE_LENGTH 3 * HASH_LENGTH

typedef int64_t trit_t;

// Copied from https://github.com/iotaledger/ccurl/blob/master/src/lib/Curl.c
#define __TRUTH_TABLE 1,  0, -1, 1, -1,  0, -1,  1,  0

static const trit_t TRUTH_TABLE[9] = {__TRUTH_TABLE};

typedef struct {
  int rounds;
  trit_t state[STATE_LENGTH];
} Curl;

static VALUE ccurl_alloc(VALUE klass) {
  rb_p(rb_str_new2("Alloc"));
  Curl *ctx = ALLOC(Curl);
  // obj = Data_Make_Struct(klass, Curl, NULL, ccurl_free, ctx);

  ctx->rounds = NUMBER_OF_ROUNDS;
  memset(ctx->state, 0, STATE_LENGTH * sizeof(trit_t));

  return Data_Wrap_Struct(klass, 0, RUBY_DEFAULT_FREE, ctx);
}

static VALUE ccurl_init(VALUE self, VALUE rounds) {
  rb_p(rb_str_new2("Init"));
  Curl *ctx;
  int requested = NUMBER_OF_ROUNDS;

  if (TYPE(rounds) != T_NIL) {
    rb_p(rb_str_new2("Here"));
    requested =  NUM2INT(rounds);
  }

  Data_Get_Struct(self, Curl, ctx);

  ctx->rounds = requested;

  return self;
}

static VALUE ccurl_rounds(VALUE self) {
  Curl *ctx;
  Data_Get_Struct(self, Curl, ctx);

  return INT2NUM(ctx->rounds);
}

static VALUE ccurl_state(VALUE self) {
  Curl *ctx;
  Data_Get_Struct(self, Curl, ctx);

  return INT2NUM(ctx->state);
}

void Init_ccurl(void) {
  VALUE iota = rb_define_module("IOTA");
  VALUE iotaCrypto = rb_define_module_under(iota, "Crypto");
  VALUE cCurl = rb_define_class_under(iotaCrypto, "CCurl", rb_cObject);

  rb_define_alloc_func(cCurl, ccurl_alloc);
  rb_define_method(cCurl, "initialize", ccurl_init, 1);
  // rb_define_method(cCurl, "absorb", ccurl_absorb, 3);
  // rb_define_method(cCurl, "squeeze", ccurl_squeeze, 3);
  // rb_define_method(cCurl, "reset", ccurl_reset, 0);
  rb_define_method(cCurl, "rounds", ccurl_rounds, 0);
  rb_define_method(cCurl, "state", ccurl_state, 0);
}
