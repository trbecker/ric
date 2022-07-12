## Preparing
~~~
# docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v /var/lib/chartmuseum/:/charts chartmuseum/chartmuseum:latest

# export CHART_REPO_URL=http://0.0.0.0:8090

# git clone "https://gerrit.o-ran-sc.org/r/ric-plt/appmgr" /appmgr

# cd /appmgr/xapp_orchestrater/dev/xapp_onboarder/

# pip3 install ./
~~~

## Deploying
~~~
# cd /hw/init
# dms_cli onboard config-file.json schema.json
# dms_cli get_charts_list
{
    "hwxapp": [
        {
            "apiVersion": "v1",
            "appVersion": "1.0",
            "created": "2022-04-05T22:19:46.698606432Z",
            "description": "Standard xApp Helm Chart",
            "digest": "22db722f42e86d8f899f23279dd24145f31a453b0696c2ed2e8c4f46d2c3411f",
            "name": "hwxapp",
            "urls": [
                "charts/hwxapp-1.0.0.tgz"
            ],
            "version": "1.0.0"
        }
    ]
}
# dms_cli install hwxapp 1.0.0 ricxapp
~~~

Then we can proceed to [e2sim](e2sim.md).
