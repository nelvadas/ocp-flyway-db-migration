# Flyway Database Migraiton in Openshift Demo

Connect on minishift cluster
``` oc login -u developer -p developer ``

Create a new project 

```oc new-project ocp-flyway-db-migration```
Connect with admin user and Grant the anyuid scc to the default service acccount in the ocp-flyway-db-migration project

```oc adm policy add-scc-to-user anyuid -z default```


Create the postgres DB application in the ocp-flyway-db-migration project
```
 oc new-app jbossdevguidebook/beosbank_posgres_db_europa:latest --name=beosbank-postgres-db-europa

--> Found Docker image dafaf18 (7 months old) from Docker Hub for "jbossdevguidebook/beosbank_posgres_db_europa:latest"
    * An image stream will be created as "beosbank-postgres-db-europa:latest" that will track this image
    * This image will be deployed in deployment config "beosbank-postgres-db-europa"
    * Port 5432/tcp will be load balanced by service "beosbank-postgres-db-europa"
      * Other containers can access this service through the hostname "beosbank-postgres-db-europa"
    * This image declares volumes and will default to use non-persistent, host-local storage.
      You can add persistent volumes later by running 'volume dc/beosbank-postgres-db-europa --add ...'
    * WARNING: Image "jbossdevguidebook/beosbank_posgres_db_europa:latest" runs as the 'root' user which may not be permitted by your cluster administrator

--> Creating resources ...
    imagestream "beosbank-postgres-db-europa" created
    deploymentconfig "beosbank-postgres-db-europa" created
    service "beosbank-postgres-db-europa" created
--> Success
    Run 'oc status' to view your app.

```
The application starts and you have a postgres pod

![Beosbank Database pod](https://github.com/nelvadas/ocp-flyway-db-migration/blob/master/beosbank-db-pod.png)

Check the database content





```git clone https://github.com/nelvadas/ocp-flyway-db-migration.git```

```cd ocp-flyway-db-migration```

``` oc create  cm sql-configmap --from-file=./sql```

