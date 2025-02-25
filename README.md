# Installing UCD Server and Agent on ROKS

* [Server Installation instructions from Knowledgecenter](https://www.ibm.com/support/knowledgecenter/SS4GSP_7.1.1/com.ibm.udeploy.install.doc/topics/docker_cloud_over.html)
* [Agent installation instructions](https://www.ibm.com/support/knowledgecenter/SS4GSP_7.1.1/com.ibm.udeploy.install.doc/topics/agent_install_helm_chart.html)

To get started you're going to need an openshift cluster running in the IBM cloud, and a client with oc installed.  Clone this repo as it has a number of yaml files that you can just run.  There are now two options to install UCD, one is to run the script, which is the quickest and easiest way.  The second way is a more step by step approach - which is useful if you need to understand how to do the install, or you need to make significant changes.


# Automated Instructions to install Urbancode Deploy(UCD) on IBM's Redhat Openshift Kubernetes Service (ROKS)
There are 6 environment variables that you can set to control the installation (or you can just modify the install.sh to change the default values).  The only one that is mandatory is the ENTITLED_REGISTRY_KEY, the others are optional with sensible default values.  I would strongly recommend changing the two passwords.

- ENTITLED_REGISTRY_KEY - the value of your entitled registry key, this is used to pull down the ucd docker images.
- NAMESPACE - the namespace that ucd will be deployed to.  If it doesnt exist, it will get created.
- MYSQL_PASSWORD - the password to the mysql database.  The mysql database is not exposed outside of the cluster.
- UCD_ADMIN_PASSWORD - the password to ucd.  the UCD ui is on the public internet, so I woudl strongly recommend this is 32 characters plus.  The defaul value is admin !!!
- UCD_RELEASE_NAME - this is the name of the helm release for ucd, and is also used as the basis of the route to the ucd server.
- UCDAGENT_RELEASE_NAME - this is the name of the helm release for the ucd agents.

Once you've set the environment variables you want to change (and have logged into your openshift cluster), then you can just simply type

```
./install-vpc.sh
```

It should take about 5 minutes to install, and you will get progress information as it proceeds.  At the end, the script will output the route and credentials for your ucd server.

# Manual instructions to install Urbancode Deploy(UCD) on IBM's Redhat Openshift Kubernetes Service (ROKS)

### ***All of the given yaml files need to be updated with your settings!***


The first step is to create a project (f.e. ***ucd***), and set the service account up to be able to run UCD (info got from createSecurityNamespacePrereqs.sh).

```
oc new-project ucd

oc adm policy add-scc-to-group anyuid system:serviceaccounts:ucd
```

Now we need to create a database server.  The easiest thing is to use mysql.  We need to create a volume claim, the database itself and a service so that ucd can acces it.
First check the storage class and fix it to the ones you want to use (f.e. ***volume.beta.kubernetes.io/storage_class=ibmc-block-gold***) 

```
oc apply -f db/mysql-pvc.yaml
oc apply -f db/mysql.yaml
oc apply -f db/mysqlservice.yaml
```

Now you need to create the database for ucd to use.  Once the pods are running, exec into the mysql pod and create the database with the following.

```
MySQL_Pod_Name=`oc get pods | grep mysql | cut -d " " -f 1`

oc exec -it $MySQL_Pod_Name /bin/bash

mysql -u root -ppassword
CREATE USER 'ibm_ucd'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE DATABASE ibm_ucd character set utf8 collate utf8_bin;
GRANT ALL ON ibm_ucd.* TO 'ibm_ucd'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
```

Now we need to create some secrets and config maps.  There are two secrets - one to access the ucd docker images, and a second to provide the default ucd admin password and sql database passwords.  Finally there is a config map to pull down the mysql drivers.  You'll need your entitled registry key here.  I also strongly recommend you change the default passwords in the ucdDBSecret.yaml file.   You can do this by `echo -n 'your password' | base64` and putting the resulting text into the file.  As it stands this will setup a ucd server with username admin, password of admin.

```
oc create secret docker-registry entitledregistry-secret --docker-username=cp --docker-password=<your entitled key goes here> --docker-server=cp.icr.io
oc patch -n ucd serviceaccount/default --type='json' -p='[{"op":"add","path":"/imagePullSecrets/-","value":{"name":"entitledregistry-secret"}}]'

oc create -f server/ucdDBSecret.yaml

oc create -f db/mysqldriverConfigMap.yaml
```

We're now ready to install the UCD server.  Review the values in myvalues.yaml before installing.  We're going to add the helm repo, and then install.

```
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
helm inspect values ibm-helm/ibm-ucd-prod > myvalues.yaml
helm install myucdrelease --values myvalues.yaml --set license.accept=true ibm-helm/ibm-ucd-prod 
```

Once the pods are up and running, we need to create a route to the ucd server. Edit the ucroute.yaml, and update the route with the url of your ocp server.  Then run the following.

```
oc apply -f server/ucdroute.yaml
```

Check you can access the ucd UI by copying the route url into a browser.  

Assuming thats all ok - we just need to do the final step.  Now you need to add an agent.

```
helm install my-ucda-release --values ucdagentvalues.yaml --set license.accept=true ibm-helm/ibm-ucda-prod
```

And thats it all completed.




## Changes

### 2021.04.06 permission error for KUBECONFIG 
* solution base: <https://access.redhat.com/solutions/2702421>
* added configmap