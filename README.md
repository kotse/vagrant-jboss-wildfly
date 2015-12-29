# vagrant-jboss-wildfly
Vagrant setup for JBoss and WildFly on Debian VM

## Motivation

1. Migrate some projects from JBoss 7 to Wildfly
2. Do not install JBoss/Wildfly on dev machine
3. Use the same environment as production

## Key points

1. After installation all `.war` files found in the `/deploy` folder will be deployed. 
    Default `hello-world-servlet.war` is added. For more info on that project [go to the repo][hello-world-servlet repo] 
2. JBoss/WildFly ports from client machine are forwarded to the host
    You can test it by connecting to `localhost:8080` from your host machine
    `hello-world-servlet` can also be used to test it - `localhost:8080/hello-world-servlet/hello`

[hello-world-servlet repo]: https://github.com/kotse/hello-world-servlet
