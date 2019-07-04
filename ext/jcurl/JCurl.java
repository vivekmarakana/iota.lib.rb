package com.vmarakana;

import java.util.Arrays;

import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyInteger;
import org.jruby.RubyNil;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

public class JCurl extends RubyObject {
  /**
   * The hash length.
   */
  public static final int HASH_LENGTH = 243;
  private static final int STATE_LENGTH = 3 * HASH_LENGTH;

  public static final int NUMBER_OF_ROUNDS = 81;
  private int numberOfRounds;

  private static final int[] TRUTH_TABLE = {1, 0, -1, 2, 1, -1, 0, 2, -1, 1, 0};
  private final int[] scratchpad = new int[STATE_LENGTH];
  private int[] state;

  /**
   * Java constructor
   * @param ruby Ruby
   * @param metaclass RubyClass
   */
  public JCurl(Ruby ruby, RubyClass rubyClass) {
    super(ruby, rubyClass);
  }

  /**
   *
   * @param context ThreadContext
   * @param klass IRubyObject
   * @param args optional (no args rounds = NUMBER_OF_ROUNDS)
   * @return new Vec3 object (ruby)
   */
  @JRubyMethod(name = "new", meta = true, rest = true)
  public static IRubyObject rbNew(ThreadContext context, IRubyObject klass, IRubyObject... args) {
    JCurl jcurl = (JCurl) ((RubyClass) klass).allocate();
    jcurl.init(context, args);
    return jcurl;
  }

  // This method is internal and not exposed
  private IRubyObject init(ThreadContext context, IRubyObject... args) {
    state = new int[STATE_LENGTH];

    // Set rounds
    if (args.length > 0 && args[0] instanceof RubyInteger) {
      numberOfRounds = ((RubyInteger) args[0]).getIntValue();
    } else {
      numberOfRounds = NUMBER_OF_ROUNDS;
    }

    return new RubyNil(context.runtime);
  }

  @JRubyMethod
  public IRubyObject transform(ThreadContext context) {
    int scratchpadIndex = 0;
    int prev_scratchpadIndex = 0;
    for (int round = 0; round < numberOfRounds; round++) {
      System.arraycopy(state, 0, scratchpad, 0, STATE_LENGTH);
      for (int stateIndex = 0; stateIndex < STATE_LENGTH; stateIndex++) {
        prev_scratchpadIndex = scratchpadIndex;
        if (scratchpadIndex < 365) {
          scratchpadIndex += 364;
        } else {
          scratchpadIndex += -365;
        }
        state[stateIndex] = TRUTH_TABLE[scratchpad[prev_scratchpadIndex] + (scratchpad[scratchpadIndex] << 2) + 5];
      }
    }

    return new RubyNil(context.runtime);
  }

  @JRubyMethod
  public IRubyObject absorb(ThreadContext context, final IRubyObject trits) {
    int offset = 0;
    int length = ((RubyArray) trits).getLength();

    do {
      System.arraycopy(trits.toJava(int[].class), offset, state, 0, length < HASH_LENGTH ? length : HASH_LENGTH);
      transform(context);
      offset += HASH_LENGTH;
    } while ((length -= HASH_LENGTH) > 0);

    return new RubyNil(context.runtime);
  }

  @JRubyMethod
  public RubyNil squeeze(ThreadContext context, final IRubyObject trits) {
    int offset = 0;
    int length = ((RubyArray) trits).getLength();

    do {
      for(; length < HASH_LENGTH; length++) {
        ((RubyArray) trits).append(context.runtime.newFixnum(0));
      }

      for (int i = 0; i < HASH_LENGTH; i++) {
        ((RubyArray) trits).store(i, context.runtime.newFixnum(state[i]));
      }

      transform(context);
      offset += HASH_LENGTH;
    } while ((length -= HASH_LENGTH) > 0);

    return new RubyNil(context.runtime);
  }

  @JRubyMethod
  public IRubyObject reset(ThreadContext context) {
    Arrays.fill(state, 0);
    return new RubyNil(context.runtime);
  }
}
