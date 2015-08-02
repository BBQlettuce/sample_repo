# Backbone Assessment

This assessment depends on `capybara-webkit` to run integration specs.
One of the dependencies of this gem is Qt, which you may need to install
separately.

via Homebrew:
```sh
$ brew update
$ brew install qt
```

via Macports:
```sh
$ sudo port selfupdate
$ sudo port install qt4-mac
```

Refer to the following link if you have trouble installing:
https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit

Lets take **1 hour**. There are two sets of specs to run, Jasmine specs
and Capybara (integration) specs.

First run the Jasmine specs by running `rake jasmine` and browse to
`localhost:8888`.

Running the integration specs requires the test database to be migrated.
Run `rake db:test:load` to get the database setup.

Then to run the integration specs, run `rspec spec/features/integration_spec.rb`.

Jasmine doesn't behave well with JST so the templates are written inline
for you.  `_.template("<%= obj.method() %>")` will create a template
function similar to how JST["posts/form"] does. Try not to let this trip
you up.

Keep in mind that the order of routes matters.

cats/:id
cats/new //=> this route will never fire, as it will match the cats/:id first.

all of the specs are under `spec/javascripts`

Take a look at routes.rb and you'll notice that posts are available from
`/api/posts`

**Topics**:
+  myBind
+  myCall
+  myCurry

**Backbone.Collection**:
+  model
+  url
+  comparator

**Backbone.Router**:
+  routes

**Backbone.View**:
+  render
+  tagName
+  events
+  initialize/listenTo
