# Documentation on RIC, first semester

## Installing RIC, manual
To get a better underatnding on the RIC intallation and possible automations, a full manual intallation of the RIC was made. The sequence of steps can be found in [RIC install - full manual](RIC install - full manual.md). This documentation goes from the intallation of the virtual machine using libvirt to having a functional RIC. 

## Deploying the hello world xapp
After the complete installation, I [deployed the hw xapp](RIC xapp deployment.md). The hw xapp is not working as intended, so we needed to debug the xapp. The debugging using gdb in docker and linux can be done using nsenter, intructions in [Running gdb inside a container with nsenter](Running gdb inside a container with nsenter.md). This resulted in not much -- notes can be found in [Debugging e2sim](Debugging e2sim.md) --, and further development in this front is forthcomming.

Other options for debugging RIC can be found in [RIC debugging](RIC debugging.md). It covers the basics doing a healthcheck, and the very basics of network tracing (tcpdump and tshark) and process tracing (strace).

The counterpart to hw-xapp is e2sim, and the compilation of e2sim can be found in [Compiling e2sim](Compiling e2sim.md)
