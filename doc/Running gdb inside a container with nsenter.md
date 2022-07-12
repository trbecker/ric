- By default, container applications are not capable of attaching trace applications (`strace`, `gdb`) to an application, as it doesn't have `SYS_PTRACE`  capabilities when it starts.
	- One can add these capabilities only when the container is started, by adding `--cap-add=SYS_PTRACE` to the `docker run` command line.
	- The other option is to run `nsenter`.
- In the host, discover the PID of the running application
~~~
# docker top ebce610a654c0ab5
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                5741                5718                0                   03:03               ?                   00:00:00            /bin/sh -c python3 /etc/xapp/init_script.py $CONFIG_FILE
root                5771                5741                0                   03:03               ?                   00:00:01            python3 /etc/xapp/init_script.py /opt/ric/config/config-file.json
root                6003                5771                0                   03:03               ?                   00:00:28            /usr/local/bin/hw_xapp_main
~~~
- We are looking for `hw_xapp_main (6003)`. Once found, we can go in with `nsenter`.
~~~
# nsenter --all --target 6003
~~~
- `--all` enters all namespaces of the PID (network, mounts, and so on). `--target` selects the PID to be used.
	- At this point, you should have a shell in the container. Install and run the applications you need.
~~~
# apt install gdb
# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 03:03 ?        00:00:00 /bin/sh -c python3 /etc/xapp/init_script.py $CONFIG_FILE
root         7     1  0 03:03 ?        00:00:01 python3 /etc/xapp/init_script.py /opt/ric/config/config-
root         8     7  0 03:03 ?        00:00:29 /usr/local/bin/hw_xapp_main
root       151     0  0 16:34 ?        00:00:00 -bash
root       156   151  0 16:34 ?        00:00:00 ps -ef

# gdb -p 8
...
(gdb)
~~~
- Note that gdb above is atteched to the PID of `hw_xapp_main` inside the PID namespace (`8`).
- If you need the debugging symbols, the consult [this document](https://nvartolomei.com/debugging-programs-running-inside-docker-containers--in-production/) on how to attach a container with debugging symbols.
- Sources:
	- https://nvartolomei.com/debugging-programs-running-inside-docker-containers--in-production/
