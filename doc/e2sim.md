[Compiling e2sim](Compiling e2sim.md)
[RIC xapp deployment](RIC xapp deployment.md)

## Running
~~~
%%about to register e2sm func desc for 0
%%about to register callback for subscription for func_id 0
Start E2 Agent (E2 Simulator
After reading input options
[SCTP] Binding client socket to source port 36422
[SCTP] Connecting to server at 127.0.0.1:36421 ...
connect: Connection refused
~~~

### Let's research
- [Traffic_steering_flows](Traffic_steering_flows.md)
	- To run, it needs the ip address of service-ricplt-__e2term__-alpha. Let's try to run with e2term.
~~~
# docker ps | grep e2term
38439a3d45e4   52c4773dbd07           "sh -c ./startup.sh"     7 hours ago   Up 7 hours             k8s_container-ricplt-e2term_deployment-ricplt-e2term-alpha-79784bd9fd-rpktf_ricplt_57341027-ef4e-4740-8703-20a8b0f4a5f3_1

# docker exec 38439a3d45e4 netstat -nl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:8088            0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:38000           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:4561            0.0.0.0:*               LISTEN     
tcp6       0      0 :::8088                 :::*                    LISTEN     
sctp                :::36422                                        LISTEN 

# docker exec 38439a3d45e4 ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.244.0.27  netmask 255.255.255.0  broadcast 0.0.0.0
        ether 6e:b1:35:31:71:a3  txqueuelen 0  (Ethernet)
        RX packets 7763  bytes 1537913 (1.5 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 7621  bytes 1016881 (1.0 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
~~~

- Run succeeds
~~~
# ./build/src/kpm/kpm_sim 10.244.0.27 36422
Starting KPM processor simJSON Test
...
[SCTP] Binding client socket to source port 36422
[SCTP] Connecting to server at 10.244.0.27:36422 ...
[SCTP] Connection established
After starting client
client_fd value is 3
looping through ran func
about to call setup request encode
After generating e2setup req
<E2AP-PDU>
    <initiatingMessage>
...
    </initiatingMessage>
</E2AP-PDU>
After XER Encoding
error length 0
error buf 
er encded is 45
in sctp send data func
data.len is 45after getting sent_len
[SCTP] Sent E2-SETUP-REQUEST
[SCTP] Waiting for SCTP data
receive data1
receive data2
~~~
- In the logs, decoding errors:
~~~
{"ts":1648675835007,"crit":"ERROR","id":"E2Terminator","mdc":{"PID":"140593128793856","POD_NAME":"deployment-ricplt-e2term-alpha-79784bd9fd-rpktf","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"[[RIC]]_E2_TERM","HOST_NAME":"ric","SYSTEM_NAME":"SEP"},"msg":"Error 2 Decoding (unpack) E2AP PDU from RAN : "}
{"ts":1648675837866,"crit":"ERROR","id":"E2Terminator","mdc":{"PID":"140593137186560","POD_NAME":"deployment-ricplt-e2term-alpha-79784bd9fd-rpktf","CONTAINER_NAME":"container-ricplt-e2term","SERVICE_NAME":"RIC_E2_TERM","HOST_NAME":"ric","SYSTEM_NAME":"SEP"},"msg":"Error 2 Decoding (unpack) E2AP PDU from RAN : "}
~~~
- Turns out, the code on  `master`  is not compatible with  `dawn`.
- With down, compilation steps are the same, and the registration completes.
~~~
[SCTP] Sent E2-SETUP-REQUEST
[SCTP] Waiting for SCTP data
receive data1
receive data2
receive data3
[SCTP] Received new data of size 33
in e2ap_handle_sctp_data()
decoding...
full buffer
 
length of data 33
result 0
index is 2
showing xer of data
<E2AP-PDU>
    <successfulOutcome>
...
    </successfulOutcome>
</E2AP-PDU>
[E2AP] Unpacked E2AP-PDU: index = 2, procedureCode = 1

[E2AP] Received SETUP-RESPONSE-SUCCESS
receive data1
receive data2
receive data3
~~~
## VIAVI simulator
- The last commit in `dawn` is below. Questions:
	- How is the data feed? By which pipe? Named? A `|` pipe?
~~~
commit 88de94233a1b3b09cc91e3b557c825ac1a80dacb (HEAD -> dawn, origin/dawn)
Author: Agustin F. Pozuelo <agustin.pozuelo@viavisolutions.com>
Date:   Mon May 31 16:28:47 2021 +0100

    Feed VIAVI data into E2 Simulator via pipe
    
    Signed-off-by: Agustin F. Pozuelo <agustin.pozuelo@viavisolutions.com>
    Change-Id: Ia3e1373764a1118d88876df9b9254fbb5c31d084
~~~
