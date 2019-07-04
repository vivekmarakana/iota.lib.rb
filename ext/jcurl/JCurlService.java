package com.vmarakana;

import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.BasicLibraryService;

public class JCurlService implements BasicLibraryService {
  private Ruby runtime;

  /**
   * Basic load method of the BasicLibraryService, this method is
   * invoked when the ruby code does the related require call.
   * @param ruby An instance of the JRuby runtime.
   * @return boolean True if everything was successful, false otherwise.
   * @throws IOException is required to match the BasicLibraryService signature
   */

  @Override
  public boolean basicLoad(final Ruby ruby) throws IOException {
    RubyModule iota = ruby.defineModule("IOTA");
    RubyModule crypto = iota.defineModuleUnder("Crypto");
    RubyClass jcurl = crypto.defineClassUnder("JCurl", ruby.getObject(), new ObjectAllocator() {
      public IRubyObject allocate(Ruby ruby1, RubyClass rubyClass) {
        return new JCurl(ruby1, rubyClass);
      }
    });

    jcurl.defineAnnotatedMethods(JCurl.class);
    return true;
  }
}
