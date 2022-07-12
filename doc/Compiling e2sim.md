- Testando para ver se o dockerfile ainda compila o e2sim.
	- Sim, mas com ações necessárias

~~~
# pwd
/home/rick/e2-interface/e2sim
# cp docker/Dockerfile .
# docker build .
~~~

- Ok, passos para compilar (incompletos, assumo um ambiente de desenvolvimento)

~~~
# apt-get update && apt-get install -y build-essential \
	git cmake libsctp-dev autoconf automake libtool \
	bison flex libboost-all-dev
# mkdir build
# cd build
# cmake .. && make package
~~~

- Isso vai criar um pacote com os seguintes arquivos:

~~~
# dpkg-deb -c /home/rick/e2-interface/e2sim/build/e2sim_1.0.0_amd64.deb
drwxr-xr-x root/root         0 2022-03-30 13:32 ./usr/
drwxr-xr-x root/root         0 2022-03-30 13:32 ./usr/local/
drwxr-xr-x root/root         0 2022-03-30 13:32 ./usr/local/lib/
-rw-r--r-- root/root    740040 2022-03-30 13:32 ./usr/local/lib/libe2sim_shared.so
~~~

- Faltam os headers...

~~~
# pwd
/home/rick/e2-interface/e2sim/build
# cmake .. -DDEV_PKG=1
# make package
# dpkg -i e2sim-dev_1.0.0_amd64.deb
~~~

- Construíndo o kpm_sim

~~~
# cd e2sim/e2sm_examples/kpm_e2sm/
# mkdir -p build
# cd build
# patch -p 1 -d ../../../.. << EOF
~~~diff --git a/e2sim/e2sm_examples/kpm_e2sm/CMakeLists.txt b/e2sim/e2sm_examples/kpm_e2sm/CMakeLists.txt
index 66fbf41..47ca6c3 100644
--- a/e2sim/e2sm_examples/kpm_e2sm/CMakeLists.txt
+++ b/e2sim/e2sm_examples/kpm_e2sm/CMakeLists.txt
@@ -17,7 +17,7 @@
 
 
 project( ricxfcpp )
-cmake_minimum_required( VERSION 3.14 )
+cmake_minimum_required( VERSION 3.10 )
 
 set( major_version "1" )               # until CI supports auto tagging; must hard set
 set( minor_version "0" )
diff --git a/e2sim/e2sm_examples/kpm_e2sm/src/kpm/CMakeLists.txt b/e2sim/e2sm_examples/kpm_e2sm/src/kpm/CMakeLists.txt
index 263d98c..d26dffd 100644
--- a/e2sim/e2sm_examples/kpm_e2sm/src/kpm/CMakeLists.txt
+++ b/e2sim/e2sm_examples/kpm_e2sm/src/kpm/CMakeLists.txt
@@ -31,6 +31,7 @@ target_link_libraries( kpm_sim pthread)
 
 install( 
     TARGETS kpm_sim
+    RUNTIME DESTINATION bin
     DESTINATION ${install_bin}
 )
 
EOF
# cmake ..
# make
...
[ 99%] Building CXX object src/kpm/CMakeFiles/kpm_sim.dir/kpm_callbacks.cpp.o
/home/rick/e2-interface/e2sim/e2sm_examples/kpm_e2sm/src/kpm/kpm_callbacks.cpp:49:10: fatal error: nlohmann/json.hpp: No such file or directory
 #include <nlohmann/json.hpp>
          ^~~~~~~~~~~~~~~~~~~
~~~

- UFFF
- Este header parece vir de https://github.com/nlohmann/json.
	- This is a single header with definitions to parse JSON.
	- Let's install it.

~~~
# mkdir -p /usr/local/include/nlohmann
# wget https://github.com/nlohmann/json/releases/download/v3.7.3/json.hpp \
	-O /usr/local/include/nlohmann/json.hpp
~~~

- Back to the install.

~~~
# make
[ 98%] Built target asn1_objects
[100%] Built target kpm_sim
~~~

## Other resources
- https://github.com/tele0x/oran-e2sim