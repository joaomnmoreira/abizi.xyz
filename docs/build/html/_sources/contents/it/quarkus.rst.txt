=======
Quarkus
=======

.. highlight:: console

Books
=====
- `Quarkus Cookbook <https://shop.oreilly.com/product/0636920353171.do>`__

Master Course
=============

- Red Hat Quarkus Master Course
    - `Video <https://www.youtube.com/watch?v=w5wQha9pO4k>`__
    - `Slides <https://dn.dev/quarkusmaster>`__
    - `Tutorial <https://​dn.dev/quarkus-tutorial>`__

References
==========

    - `Quarkus.io <https://quarkus.io>`__
    - `Graalvm.org <https://www.graalvm.org/>`__

VSCODE Extensions
-----------------

    - View `Tutorial <https://​dn.dev/quarkus-tutorial>`__

Commands
--------

- Compile APP (jar)

::
    
    mvn package

- Run compiled APP (jar)

::
    
    java -jar target/fruits-app-1.0-SNAPSHOT-runner.jar

- Compile APP (native with graalvm)

::
    
    mvn package -Pnative

- Run compiled APP (native)

::
    
    ./target/fruits-app-1.0-SNAPSHOT-runner

- Run APP (development mode, aka live coding)

::
    
    ./mvnw quarkus:dev

- Create kubernetes package

::
    
    ./mvnw clean package -DskipTests -Dquarkus.container-image.push=true
