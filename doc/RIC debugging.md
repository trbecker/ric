## Healthcheck
~~~
# docker ps | grep e2mgr
eca32c1d58f3   b1dcc7abb01a           "sh -c './main  -por…"   5 days ago   Up 5 days             k8s_container-ricplt-e2mgr_deployment-ricplt-e2mgr-74fcc68b6b-tjvx9_ricplt_29241806-d7f0-422a-b4ef-9c5c4595cad0_0

# docker exec eca32c1d58f3 ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.244.0.37  netmask 255.255.255.0  broadcast 0.0.0.0
        ether 7a:f9:e1:72:3c:6b  txqueuelen 0  (Ethernet)
        RX packets 809107  bytes 95547822 (95.5 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 940126  bytes 87989099 (87.9 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# docker exec eca32c1d58f3 netstat -nlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:4561            0.0.0.0:*               LISTEN      9/./main            
tcp        0      0 0.0.0.0:3801            0.0.0.0:*               LISTEN      9/./main            
tcp6       0      0 :::3800                 :::*                    LISTEN      9/./main

# curl -s http://10.244.0.37:3800/v1/nodeb/states | jq
[
  {
    "inventoryName": "gnb_734_733_b5c67788",
    "globalNbId": {
      "plmnId": "373437",
      "nbId": "10110101110001100111011110001"
    },
    "connectionStatus": "CONNECTED"
  }
]

~~~
## Networking
Usually can be done with `tcpdump`. The entire [RIC](RIC.md) can be debugged using the `cni0` interface. To capture the data, the following command can be used. __TODO:___ More dateiled information in using `tcpdump` later.
~~~
tcpdump -i cni0 -w ric.pcap
~~~
The see the data captured, `wireshark` can be used, but my preference is `tshark`. `tshark` is a command line interface from `wireshark`, and uses the same filters as `wireshark`.
~~~
tshark -r ric.pcap
~~~
__TODO:__ More detailed information on `tshark` usage later.
~~~
# tshark -r ric.pcap -Y 'ip.addr == 10.244.0.38 && ip.addr == 10.244.0.1 && sctp.port == 36422'
Running as user "root" and group "root". This could be dangerous.
  186   4.269708   10.244.0.1 → 10.244.0.38  SCTP 314 INIT 
  187   4.270191  10.244.0.38 → 10.244.0.1   SCTP 530 INIT_ACK 
  188   4.270295   10.244.0.1 → 10.244.0.38  SCTP 502 COOKIE_ECHO 
  189   4.270758  10.244.0.38 → 10.244.0.1   SCTP 50 COOKIE_ACK 
  190   4.310865   10.244.0.1 → 10.244.0.38  X2AP 574 HandoverCancel[Malformed Packet]
  191   4.310959  10.244.0.38 → 10.244.0.1   SCTP 62 SACK 
  276   4.344313  10.244.0.38 → 10.244.0.1   X2AP 98 
  277   4.344393   10.244.0.1 → 10.244.0.38  SCTP 62 SACK 
~~~
A packet in detail.
~~~
# tshark -r ric.pcap -Y 'frame.number == 190' -V
Running as user "root" and group "root". This could be dangerous.
Frame 190: 574 bytes on wire (4592 bits), 574 bytes captured (4592 bits) ...
Ethernet II, Src: ce:d9:c3:f0:18:f3 (ce:d9:c3:f0:18:f3), Dst: b2:24:c2:0a:af:e0 (b2:24:c2:0a:af:e0) ...
Internet Protocol Version 4, Src: 10.244.0.1, Dst: 10.244.0.38 ...
Stream Control Transmission Protocol, Src Port: 36422 (36422), Dst Port: 36422 (36422)
    Source port: 36422
    Destination port: 36422
    Verification tag: 0x3eb1a6a7
    [Association index: 0]
    Checksum: 0xe0c1b453 [unverified]
    [Checksum Status: Unverified]
    DATA chunk(ordered, complete segment, TSN: 3179443422, SID: 0, SSN: 0, PPID: 0, payload length: 509 bytes)
        Chunk type: DATA (0)
            0... .... = Bit: Stop processing of the packet
            .0.. .... = Bit: Do not report
        Chunk flags: 0x03
            .... ...1 = E-Bit: Last segment
            .... ..1. = B-Bit: First segment
            .... .0.. = U-Bit: Ordered delivery
            .... 0... = I-Bit: Possibly delay SACK
        Chunk length: 525
        Transmission sequence number: 3179443422
        Stream identifier: 0x0000
        Stream sequence number: 0
        Payload protocol identifier: not specified (0)
        Chunk padding: 000000
EUTRAN X2 Application Protocol (X2AP)
    X2AP-PDU: initiatingMessage (0)
        initiatingMessage
            procedureCode: id-handoverCancel (1)
            criticality: reject (0)
            value
                HandoverCancel
                    protocolIEs: 2 items
                        Item 0: id-E-RABs-NotAdmitted-List
                            ProtocolIE-Field
                                id: id-E-RABs-NotAdmitted-List (3)
                                criticality: reject (0)
                                value
                                    E-RAB-List: 1 item
                                        Item 0: unknown (14132)
                                            ProtocolIE-Single-Container
                                                id: Unknown (14132)
                                                criticality: reject (0)
[Malformed Packet: X2AP]
    [Expert Info (Error/Malformed): Malformed Packet (Exception occurred)]
        [Malformed Packet (Exception occurred)]
        [Severity level: Error]
        [Group: Malformed]
~~~
## Execution
~~~
$ strace -T -tt -f -s 4096 -o ~/kpm_sim.txt build/src/kpm/kpm_sim 10.244.0.38 36422
~~~
