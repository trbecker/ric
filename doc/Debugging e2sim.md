## gdb
gdb shows that `kmp_sim` is waiting for data.
- Start `gdb`. 
~~~
gdb ./build/src/kpm/kpm_sim 10.244.0.16 36422
...
(gdb) r 10.244.0.16 36422
... log messages ...
[E2AP] Unpacked E2AP-PDU: index = 2, procedureCode = 1

[E2AP] Received SETUP-RESPONSE-SUCCESS
receive data1
receive data2
~~~
- At this point, the program doesn't progress. Hit `ctrl+z`  to stop the program.
~~~
(gdb) where
#0  0x00007ffff7bc58da in __libc_recv (fd=3, buf=0x7fffffff74c0, len=10000, flags=0) at ../sysdeps/unix/sysv/linux/recv.c:28
#1  0x00005555555eeda5 in sctp_receive_data (socket_fd=@0x555555852374: 3, data=...) at /home/rick/e2-interface/e2sim/src/SCTP/e2sim_sctp.cpp:278
#2  0x00005555555ea333 in E2Sim::run_loop (this=0x555555852240 <e2sim>, argc=3, argv=0x7fffffffe478) at /home/rick/e2-interface/e2sim/src/base/e2sim.cpp:195
#3  0x0000555555579a41 in main ()
~~~
- Logs for `hw` show nothing unusual: only communications with `e2term` and `a1mediator`
- Continuing the debugging.
~~~
191   LOG_I("[SCTP] Waiting for SCTP data");
192 
193   while(1) //constantly looking for data on SCTP interface
194   {
195     if(sctp_receive_data(client_fd, recv_buf) <= 0)
196       break;
197 
198     LOG_I("[SCTP] Received new data of size %d", recv_buf.len);
199 
200     e2ap_handle_sctp_data(client_fd, recv_buf, xmlenc, this);
201     if (xmlenc) xmlenc = false;
202   }
~~~
## Logs
~~~
143   for (std::pair<long, OCTET_STRING_t*> elem : ran_functions_registered) {
144     printf("looping through ran func\n");
145     encoding::ran_func_info next_func;
146 
147     next_func.ranFunctionId = elem.first;
148     next_func.ranFunctionDesc = elem.second;
149     next_func.ranFunctionRev = (long)2;
150     all_funcs.push_back(next_func);
151   }



looping through ran func
about to call setup request encode
~~~
- Are we connected to the correct place? Let's try to connect to the rmr manager.
- Is the function revision correct?
- Is hw well? It seems to be doing nothing.

## Checking `hw_xapp_main`
- [Running gdb inside a container with nsenter](doc/Running gdb inside a container with nsenter.md)
~~~
(gdb) thr ap all bt

Thread 13 (Thread 0x7f0612ffd700 (LWP 20)):
#0  0x00007f063847d6d6 in futex_abstimed_wait_cancelable (private=0, abstime=0x0, expected=0, 
    futex_word=0x55b66f7f6828) at ../sysdeps/unix/sysv/linux/futex-internal.h:205
#1  do_futex_wait (sem=sem@entry=0x55b66f7f6828, abstime=0x0) at sem_waitcommon.c:111
#2  0x00007f063847d7c8 in __new_sem_wait_slow (sem=0x55b66f7f6828, abstime=0x0) at sem_waitcommon.c:181
#3  0x00007f0638698ed1 in rmr_mt_rcv (vctx=0x55b66f7ec240, mbuf=0x7f0600000b40, max_wait=-1)
    at /w/workspace/ric-plt-lib-rmr-rt-cmake-packagecloud-stage-master/src/rmr/si/src/rmr_si.c:920
#4  0x00007f0638697efe in rmr_rcv_msg (vctx=0x55b66f7ec240, old_msg=0x7f0600000b40)
    at /w/workspace/ric-plt-lib-rmr-rt-cmake-packagecloud-stage-master/src/rmr/si/src/rmr_si.c:399
#5  0x000055b66e21da7d in void XappRmr::xapp_rmr_receive<XappMsgHandler>(XappMsgHandler&&, XappRmr*) ()
#6  0x00007f0637f9d6df in ?? () from /usr/lib/x86_64-linux-gnu/libstdc++.so.6
#7  0x00007f06384746db in start_thread (arg=0x7f0612ffd700) at pthread_create.c:463
#8  0x00007f06379f888f in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:95

Thread 12 (Thread 0x7f06137fe700 (LWP 19)):
#0  runtime.futex () at /opt/go/1.12/src/runtime/sys_linux_amd64.s:536
#1  0x000055b66e24952b in runtime.futexsleep (addr=0xc000023648, val=0, ns=-1)
    at /opt/go/1.12/src/runtime/os_linux.go:46
#2  0x000055b66e229a55 in runtime.notesleep (n=0xc000023648)
    at /opt/go/1.12/src/runtime/lock_futex.go:151
#3  0x000055b66e251495 in runtime.stopm () at /opt/go/1.12/src/runtime/proc.go:1936
#4  0x000055b66e252610 in runtime.findrunnable (gp=0xc00002e000, inheritTime=false)
    at /opt/go/1.12/src/runtime/proc.go:2399
#5  0x000055b66e253240 in runtime.schedule () at /opt/go/1.12/src/runtime/proc.go:2525
#6  0x000055b66e253567 in runtime.park_m (gp=0xc000001980) at /opt/go/1.12/src/runtime/proc.go:2605
#7  0x000055b66e275883 in runtime.mcall () at /opt/go/1.12/src/runtime/asm_amd64.s:299
#8  0x0000000000000000 in ?? ()

Thread 11 (Thread 0x7f0613fff700 (LWP 18)):
#0  runtime.futex () at /opt/go/1.12/src/runtime/sys_linux_amd64.s:536
#1  0x000055b66e24952b in runtime.futexsleep (addr=0xc0000759c8, val=0, ns=-1)
    at /opt/go/1.12/src/runtime/os_linux.go:46
#2  0x000055b66e229a55 in runtime.notesleep (n=0xc0000759c8)
    at /opt/go/1.12/src/runtime/lock_futex.go:151
#3  0x000055b66e251495 in runtime.stopm () at /opt/go/1.12/src/runtime/proc.go:1936
#4  0x000055b66e252610 in runtime.findrunnable (gp=0xc00002e000, inheritTime=false)
    at /opt/go/1.12/src/runtime/proc.go:2399
#5  0x000055b66e253240 in runtime.schedule () at /opt/go/1.12/src/runtime/proc.go:2525
#6  0x000055b66e253567 in runtime.park_m (gp=0xc000000180) at /opt/go/1.12/src/runtime/proc.go:2605
#7  0x000055b66e275883 in runtime.mcall () at /opt/go/1.12/src/runtime/asm_amd64.s:299
#8  0x0000000000000000 in ?? ()

Thread 10 (Thread 0x7f062ca77700 (LWP 17)):
#0  runtime.futex () at /opt/go/1.12/src/runtime/sys_linux_amd64.s:536
#1  0x000055b66e24952b in runtime.futexsleep (addr=0xc0000232c8, val=0, ns=-1)
    at /opt/go/1.12/src/runtime/os_linux.go:46
#2  0x000055b66e229a55 in runtime.notesleep (n=0xc0000232c8)
    at /opt/go/1.12/src/runtime/lock_futex.go:151
#3  0x000055b66e251495 in runtime.stopm () at /opt/go/1.12/src/runtime/proc.go:1936
#4  0x000055b66e254a0e in runtime.exitsyscall0 (gp=0xc000001980)
    at /opt/go/1.12/src/runtime/proc.go:3128
#5  0x000055b66e275883 in runtime.mcall () at /opt/go/1.12/src/runtime/asm_amd64.s:299
#6  0x0000000000000000 in ?? ()
~~~
