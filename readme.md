# Google gperftools + libunwind for CentOS 7 64bit

RPMs built are saved to

* `/svr-setup/cmm-gperftools-2.6.3-1.el7.x86_64.rpm`
* `/svr-setup/cmm-libunwind-1.2.1-1.el7.x86_64.rpm`

```
cd /svr-setup
yum localinstall cmm-libunwind-1.2.1-1.el7.x86_64.rpm cmm-gperftools-2.6.3-1.el7.x86_64.rpm 
```

```
yum info cmm-gperftools -q                   
Installed Packages
Name        : cmm-gperftools
Arch        : x86_64
Version     : 2.6.3
Release     : 1.el7
Size        : 24 M
Repo        : installed
Summary     : gperftools-2.6.3 for centminmod.com LEMP stack installs
URL         : https://centminmod.com
License     : unknown
Description : gperftools-2.6.3 for centminmod.com LEMP stacks
```

```
yum info cmm-libunwind -q
Installed Packages
Name        : cmm-libunwind
Arch        : x86_64
Version     : 1.2.1
Release     : 1.el7
Size        : 2.5 M
Repo        : installed
Summary     : libunwind-1.2.1 for centminmod.com LEMP stack installs
URL         : https://centminmod.com
License     : unknown
Description : libunwind-1.2.1 for centminmod.com LEMP stacks
```

```
rpm -qa --changelog cmm-gperftools
* Tue Mar 06 2018 George Liu <centminmod.com> 1.2.1
- gperftools 2.6.3 for centminmod.com LEMP stack installs
```

```
rpm -qa --changelog cmm-libunwind  
* Tue Mar 06 2018 George Liu <centminmod.com> 1.2.1
- libunwind 1.2.1 for centminmod.com LEMP stack installs
```

```
rpm -ql cmm-gperftools 
/usr/local/bin/pprof
/usr/local/include/google/heap-checker.h
/usr/local/include/google/heap-profiler.h
/usr/local/include/google/malloc_extension.h
/usr/local/include/google/malloc_extension_c.h
/usr/local/include/google/malloc_hook.h
/usr/local/include/google/malloc_hook_c.h
/usr/local/include/google/profiler.h
/usr/local/include/google/stacktrace.h
/usr/local/include/google/tcmalloc.h
/usr/local/include/gperftools/heap-checker.h
/usr/local/include/gperftools/heap-profiler.h
/usr/local/include/gperftools/malloc_extension.h
/usr/local/include/gperftools/malloc_extension_c.h
/usr/local/include/gperftools/malloc_hook.h
/usr/local/include/gperftools/malloc_hook_c.h
/usr/local/include/gperftools/nallocx.h
/usr/local/include/gperftools/profiler.h
/usr/local/include/gperftools/stacktrace.h
/usr/local/include/gperftools/tcmalloc.h
/usr/local/lib/libprofiler.a
/usr/local/lib/libprofiler.la
/usr/local/lib/libprofiler.so
/usr/local/lib/libprofiler.so.0
/usr/local/lib/libprofiler.so.0.4.16
/usr/local/lib/libtcmalloc.a
/usr/local/lib/libtcmalloc.la
/usr/local/lib/libtcmalloc.so
/usr/local/lib/libtcmalloc.so.4
/usr/local/lib/libtcmalloc.so.4.5.1
/usr/local/lib/libtcmalloc_and_profiler.a
/usr/local/lib/libtcmalloc_and_profiler.la
/usr/local/lib/libtcmalloc_and_profiler.so
/usr/local/lib/libtcmalloc_and_profiler.so.4
/usr/local/lib/libtcmalloc_and_profiler.so.4.5.1
/usr/local/lib/libtcmalloc_debug.a
/usr/local/lib/libtcmalloc_debug.la
/usr/local/lib/libtcmalloc_debug.so
/usr/local/lib/libtcmalloc_debug.so.4
/usr/local/lib/libtcmalloc_debug.so.4.5.1
/usr/local/lib/libtcmalloc_minimal.a
/usr/local/lib/libtcmalloc_minimal.la
/usr/local/lib/libtcmalloc_minimal.so
/usr/local/lib/libtcmalloc_minimal.so.4
/usr/local/lib/libtcmalloc_minimal.so.4.5.1
/usr/local/lib/libtcmalloc_minimal_debug.a
/usr/local/lib/libtcmalloc_minimal_debug.la
/usr/local/lib/libtcmalloc_minimal_debug.so
/usr/local/lib/libtcmalloc_minimal_debug.so.4
/usr/local/lib/libtcmalloc_minimal_debug.so.4.5.1
/usr/local/lib/pkgconfig/libprofiler.pc
/usr/local/lib/pkgconfig/libtcmalloc.pc
/usr/local/lib/pkgconfig/libtcmalloc_debug.pc
/usr/local/lib/pkgconfig/libtcmalloc_minimal.pc
/usr/local/lib/pkgconfig/libtcmalloc_minimal_debug.pc
/usr/local/share/doc/gperftools/AUTHORS
/usr/local/share/doc/gperftools/COPYING
/usr/local/share/doc/gperftools/ChangeLog
/usr/local/share/doc/gperftools/ChangeLog.old
/usr/local/share/doc/gperftools/INSTALL
/usr/local/share/doc/gperftools/NEWS
/usr/local/share/doc/gperftools/README
/usr/local/share/doc/gperftools/README_windows.txt
/usr/local/share/doc/gperftools/TODO
/usr/local/share/doc/gperftools/cpuprofile-fileformat.html
/usr/local/share/doc/gperftools/cpuprofile.html
/usr/local/share/doc/gperftools/designstyle.css
/usr/local/share/doc/gperftools/heap-example1.png
/usr/local/share/doc/gperftools/heap_checker.html
/usr/local/share/doc/gperftools/heapprofile.html
/usr/local/share/doc/gperftools/index.html
/usr/local/share/doc/gperftools/overview.dot
/usr/local/share/doc/gperftools/overview.gif
/usr/local/share/doc/gperftools/pageheap.dot
/usr/local/share/doc/gperftools/pageheap.gif
/usr/local/share/doc/gperftools/pprof-test-big.gif
/usr/local/share/doc/gperftools/pprof-test.gif
/usr/local/share/doc/gperftools/pprof-vsnprintf-big.gif
/usr/local/share/doc/gperftools/pprof-vsnprintf.gif
/usr/local/share/doc/gperftools/pprof_remote_servers.html
/usr/local/share/doc/gperftools/spanmap.dot
/usr/local/share/doc/gperftools/spanmap.gif
/usr/local/share/doc/gperftools/t-test1.times.txt
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.1024.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.128.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.131072.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.16384.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.2048.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.256.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.32768.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.4096.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.512.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.64.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.65536.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspercpusec.vs.threads.8192.bytes.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.1.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.12.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.16.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.2.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.20.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.3.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.4.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.5.threads.png
/usr/local/share/doc/gperftools/tcmalloc-opspersec.vs.size.8.threads.png
/usr/local/share/doc/gperftools/tcmalloc.html
/usr/local/share/doc/gperftools/threadheap.dot
/usr/local/share/doc/gperftools/threadheap.gif
/usr/local/share/man/man1/pprof.1
```

```
rpm -ql cmm-libunwind  
/usr/local/include/libunwind-common.h
/usr/local/include/libunwind-coredump.h
/usr/local/include/libunwind-dynamic.h
/usr/local/include/libunwind-ptrace.h
/usr/local/include/libunwind-x86_64.h
/usr/local/include/libunwind.h
/usr/local/include/unwind.h
/usr/local/lib/libunwind-coredump.a
/usr/local/lib/libunwind-coredump.la
/usr/local/lib/libunwind-coredump.so
/usr/local/lib/libunwind-coredump.so.0
/usr/local/lib/libunwind-coredump.so.0.0.0
/usr/local/lib/libunwind-generic.a
/usr/local/lib/libunwind-generic.so
/usr/local/lib/libunwind-ptrace.a
/usr/local/lib/libunwind-ptrace.la
/usr/local/lib/libunwind-ptrace.so
/usr/local/lib/libunwind-ptrace.so.0
/usr/local/lib/libunwind-ptrace.so.0.0.0
/usr/local/lib/libunwind-setjmp.a
/usr/local/lib/libunwind-setjmp.la
/usr/local/lib/libunwind-setjmp.so
/usr/local/lib/libunwind-setjmp.so.0
/usr/local/lib/libunwind-setjmp.so.0.0.0
/usr/local/lib/libunwind-x86_64.a
/usr/local/lib/libunwind-x86_64.la
/usr/local/lib/libunwind-x86_64.so
/usr/local/lib/libunwind-x86_64.so.8
/usr/local/lib/libunwind-x86_64.so.8.0.1
/usr/local/lib/libunwind.a
/usr/local/lib/libunwind.la
/usr/local/lib/libunwind.so
/usr/local/lib/libunwind.so.8
/usr/local/lib/libunwind.so.8.0.1
/usr/local/lib/pkgconfig/libunwind-coredump.pc
/usr/local/lib/pkgconfig/libunwind-generic.pc
/usr/local/lib/pkgconfig/libunwind-ptrace.pc
/usr/local/lib/pkgconfig/libunwind-setjmp.pc
/usr/local/lib/pkgconfig/libunwind.pc
```