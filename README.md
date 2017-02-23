# Le Hasard Ludique

## Current versions

* dev : v0.1
* staging : v0.1
* prod. : v0.0

---

## Installation

### Ruby version

2.4.0

### Rails version

5.0.1

### Required environement variables

`DATABASE_URL`
`GA_UID` (Google Analytics)
`SECRET_KEY_BASE`

_AWS_
`AWS_ACCESS_KEY_ID`
`AWS_SECRET_ACCESS_KEY`
`AWS_REGION`
`AWS_BUCKET`
`AWS_ENDPOINT`

### Running script (cf. Procfile)

`web: bundle exec passenger start -p $PORT --max-pool-size 3`

### Database creation & initialization

In production & staging, please use `DATABASE_URL` env.

```
rake db:create
rake db:migrate
```

## Gems

### Noteworthy gems

* gem 'passenger' (web server)
* gem 'sorcery' (user authentication)
* gem 'cancancan' (abilities)
<!-- * gem 'carrierwave' (image upload) -->

#### SimpleForm with BootStrap

```
simple_form_for(@user, html: { class: 'form-horizontal' }) do |form|
```
See https://github.com/plataformatec/simple_form

### Tasks

...

### Services 

n/a

---

## Release notes

### v0.1 (Users & B.O.)

* create User Model
* Front
    * login page
    * flash messages
* Admin:
    * base & style (inc. plugins DataTable, select2)
    * users' list, show & forms
    * flash messages
    * abalities: base (all rights for adminstrators)

### v0.0

* App. creation
* Waiting page integration
