# Le Hasard Ludique

## Current versions

* dev : v0.3
* staging : v0.3
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
* gem 'carrierwave' (image upload)

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

### v0.3 (Basic pages)

* Pages:
    * create model, controllers & abilities
    * model's methods (page_url, facebook_url, ect.)
    * admin views (list, details, form)
    * front integration
* Sharing abalities (og, digest, url)
* CKEditor:
    * implementation, configuration & styles
* Carousel integration
* Gallery in modal integration
* Global:
    * helper methods:
        * `render_header`
        * `render_gallery`
        * `render_og_meta`
        * `link_from` (generate link from `xx > Object:id`, `xx > …`, etc.)
    * gems update
* recette:
    * admin: catch error impossible deletion (linked resource)
    * Gallery: images form, add link to get back new resources


### v0.2 (Images & galleries)

* gems: carrierwave, fog-aws, mini_magick ; instal. & config.
* Resource (image):
    * create model, uplader, controller
    * admin views: list form, details
    * abilities
* Galleries:
    * create model, controller
    * admin views: list form, details
    * abilities
* ImageShip (gallery <> resource link)
    * create model
    * validations
* Admin:
    * improve style
    * progess bar (JS & style)


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
