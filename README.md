# scholae-web

## How to configure dev environment

- Install JDK 1.8
- Install IntelliJ IDEA
- Install Haxe plugin for Intellij IDEA
- Install NodeJS
- Install NPM
- Run "npm install" in the client directory
- Run "npm install -g browserify"
- Install and configure apache + php + localbuild/site as virtual host scholae.lambda-calculus.ru
- Enable mod_rewrite in the apache configuration
- On Windows increase ThreadStackSize to 8Mb for PHP mpm_winnt_module
- Put scholae.lambda-calculus.ru to hosts
- Install and configure mysql
- Create DB with name scholae and add user scholae with password that in the configuration
- Learn about RabbitMQ: https://www.rabbitmq.com/documentation.html
- Install and run RabbitMQ
- Enable Managment UI: rabbitmq-plugins enable rabbitmq_management

```bash
rabbitmqadmin declare vhost name=scholae
rabbitmqadmin -V scholae declare queue name=jobs_common durable=true
rabbitmqadmin -V scholae declare exchange name=jobs durable=true type=fanout
rabbitmqadmin -V scholae declare binding source=jobs destination=jobs_common routing_key=common
rabbitmqadmin declare user name=scholae password=scholae tags=administrator
rabbitmqadmin declare permission vhost=scholae user=scholae read=true write=true configure=true
```

- Build the whole project
- Run the worker "neko /localbuild/scholae_worker.n"
