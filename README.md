Symfony 2 Vagrant Skeleton
========================

Skeleton for Symfony 2 application with Vagrant

git clone git@github.com:vicentgodella/symfony2-vagrant-skeleton.git

Inside project folder,

In file '/etc/hosts' add:

    127.0.0.1 sf2-vagrant.dev

Comment this lines in web/app_dev.php:

    if (isset($_SERVER['HTTP_CLIENT_IP'])
    || isset($_SERVER['HTTP_X_FORWARDED_FOR'])
    || !in_array(@$_SERVER['REMOTE_ADDR'], array('127.0.0.1', 'fe80::1', '::1'))
    ) {
        header('HTTP/1.0 403 Forbidden');
        exit('You are not allowed to access this file. Check '.basename(__FILE__).' for more information.');
    }

Type http://sf2-vagrant.dev:8080/app_dev.php in browser.