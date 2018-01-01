# Flyway Database Migraiton in Openshift Demo

Connect on minishift cluster
``` oc login -u developer -p developer ``

Create a new project 

```oc new-project ocp-flyway-db-migration```


Connect as admin rant the anyuid scc to the default service acccount in the ocp-flyway-db-migration project

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
* List the pods in the current project
```
$ oc get pods
NAME                                 READY     STATUS    RESTARTS   AGE
beosbank-posgres-db-europa-1-p16bx   1/1       Running   1          22h
```

* Connect to the running db pod using oc rsh command 
```
ocp-flyway-db-migration$ oc rsh beosbank-posgres-db-europa-1-p16bx
# psql -U postgres
psql (9.6.2)
Type "help" for help.
```
* Check the database list with \l
```
postgres=# \l
                                    List of databases
      Name       |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------------+----------+----------+------------+------------+-----------------------
 beosbank-europa | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres        | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |          |            |            | postgres=CTc/postgres
 template1       | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |          |            |            | postgres=CTc/postgres
(4 rows)
```
* Connect to the beosbank db \connect   and list relations \d

```
postgres=# \connect beosbank-europa
You are now connected to database "beosbank-europa" as user "postgres".
beosbank-europa=#

beosbank-europa=# \d
             List of relations
 Schema |       Name       | Type  | Owner
--------+------------------+-------+-------
 public | eu_customer      | table | root
 public | eu_moneytransfer | table | root
(2 rows)
```


* display the content of the eu_customer table

```
beosbank-europa=# select * from eu_customer;
 id |   city    | country  |      street       |  zip   | birthdate  | firstname  | lastname
----+-----------+----------+-------------------+--------+------------+------------+-----------
  1 | Berlin    | Germany  | brand burgStrasse | 10115  | 1985-06-20 | Yanick     | Modjo
  2 | Bologna   | Italy    | place Venice      | 40100  | 1984-11-21 | Mirabeau   | Luc
  3 | Paris     | France   | Bld DeGaule       | 75001  | 2000-02-07 | Noe        | Nono
  4 | Chatillon | France   | Avenue JFK        | 55     | 1984-02-19 | Landry     | Kouam
  5 | Douala    | Cameroon | bld Liberte       | 1020   | 1996-04-21 | Ghislain   | Kamga
  6 | Yaounde   | Cameroon | Hypodrome         | 1400   | 1983-11-18 | Nathan     | Brice
  7 | Bruxelles | Belgium  | rue Van Gogh      | 1000   | 1980-09-06 | Yohan      | Pieter
  8 | London    | UK       | street Lavoisier  | 208    | 1990-01-01 | John       | Doe
  9 | Bamako    | Mali     | Rue Modibo Keita  | 30     | 1979-05-17 | Mohamed    | Diallo
 10 | Cracovie  | Pologne  | Avenue Vienne     | 434    | 1983-05-17 | Souleymann | Njifenjou
 11 | Chennai   | India    | Gandhi street     | 600001 | 1990-02-13 | Anusha     | Mandalapu
 12 | Sao Polo  | Brasil   | samba bld         | 69400  | 1994-02-13 | Adriana    | Pinto
(12 rows)
```



```git clone https://github.com/nelvadas/ocp-flyway-db-migration.git```

```cd ocp-flyway-db-migration```

``` oc create  cm sql-configmap --from-file=./sql```

