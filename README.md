# Launcher

[![Coverage Status](https://coveralls.io/repos/davidkelley/launcher/badge.png?branch=master)](https://coveralls.io/r/davidkelley/launcher?branch=master) [![Build Status](https://travis-ci.org/davidkelley/launcher.png?branch=master)](https://travis-ci.org/davidkelley/launcher) [![Code Climate](https://codeclimate.com/repos/530a5106e30ba03a0e009dc2/badges/dd3aa794571db1563173/gpa.png)](https://codeclimate.com/repos/530a5106e30ba03a0e009dc2/feed) [![Dependency Status](https://gemnasium.com/davidkelley/launcher.png)](https://gemnasium.com/davidkelley/launcher)


The Launcher gem enables you to create, update, delete and interrogate your AWS Cloudformations within a specific region. 

Whilst enabling you to easily launch your templates, it facilitates cross-dependencies in the form of parameter discovery. This allows
you to separate your resources into different templates, and layer your infrastructure in a more structured way, whilst still be able to refer to
parameters defined in other templates.

Parameters can either be passed in via the command line in the form of a hash (`--params key:value foo:bar a:b`), discovered from **pre-existing cloudformation outputs**
and from one or multiple configuration files (`--config-files path/to/config/a.yml path/to/another/config.yml`). You can even combine all three if you like.

## Installation

You can include the launcher gem within your current solution, by adding the following line to your `Gemfile`:

    gem 'launcher'

And then execute:

    $ bundle

Or install it as a system gem:

    $ gem install launcher

## Configuring AWS

An AWS Access Key and Secret with sufficient permissions are required for launching Cloudformations. It is recommended to use a [locked down IAM Resource](http://docs.aws.amazon.com/IAM/latest/UserGuide/Using_Identifiers.html) that is capable of the following permission actions:

Launcher will attempt to discover AWS Credentials from the command line, a configuration file, and the environment. If credentials are present in all locations, Launcher will use credentials in the following priority:

* Credentials from the Command Line (`--access-key-id XXXX --secret-access-key XXXX`)
* From a configuration file located at (`~/.aws/config`)
* From the environment (`ENV`)

#### Creating a Configuration File

1. Create the following file: `~/.aws/config`. Where the `~` symbol represents the path to your user home directory. 
2. Insert the following contents, inserting your AWS credentials:

```
[default]
aws_access_key_id=<your_key>
aws_secret_access_key=<your_secret_key>
region=eu-west-1
```

 _Note: This follows the defacto configuration as described by AWS for the [AWS Command Line Interface](http://aws.amazon.com/cli/)._

#### Setting Environment Variables

1. Inside a terminal or environment file, set the following environment variables: 

```
AWS_ACCESS_KEY=<your_key>
AWS_SECRET_KEY=<your_secret_key>
```

## Getting Started

Run `launcher help` to see an exhaustive list of available commands. Below are some worked examples to help you get started:

### Listing all discoverable parameters

Currently, all discoverable parameters are retrieved from the outputs of pre-existing Cloudformations. **It is assumed that all keys are unique**.

Once you have configured AWS correctly, running `launcher list` will display all the discovered keys and values that will be used to create and update your cloudformations.

### Describing existing Cloudformations

TODO

### Launching a new Cloudformation

You can launch a new cloudformation with several parameters, although only one is required (`--template`). If you choose to omit the name parameter, given a template
file named `application.cloudformation.template`, a Cloudformation will be created with the name `application`. Such that any characters preceeding the first `.` will be used
to form the name.

#### Example of Launching a new Cloudformation

    $ launcher stack create --name my_application --template path/to/my/application.template --params GitRepo:a_url ImageId:ami-38fa829h 

### Updating an existing Cloudformation

You can update a Cloudformation at anytime using a command similar to:

    $ launcher stack update --template path/to/my/my_application.template

It is important to note here, that when compared with the previous example of creating a new template, the keys `GitRepo` and `ImageId` are now discoverable and therefore
do not need to be supplied.

Furthermore, the template filename in this example has been renamed to `my_application.template` and therefore, the name of the Cloudformation to update is now derivable.

## Contributing

A `Vagrantfile` has been setup to help you boot up an isolated development environment. Whilst this optional, it is definitely preferable. Check out [this blog post](http://davidkelley.me/development/2014/02/24/vagrant-chef-berkshelf-a-match-made-in-heaven.html) on getting started with Vagrant. 

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write passing tests for your feature using [RSpec](http://betterspecs.org/) and [Cucumber](http://cukes.info/)/[Aruba](https://github.com/cucumber/aruba)
4. Include [Yardoc](http://yardoc.org/) Comments for the code you have written.
5. Test your Yardoc comments work (`yard server`).
6. Update or Create any relevant documentation in the Wiki and Readme.
7. Commit your changes (`git commit -am 'Add some feature'`)
8. Push to the branch (`git push origin my-new-feature`)
9. Create new Pull Request and document your changes.
