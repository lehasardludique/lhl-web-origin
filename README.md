# Le Hasard Ludique

## Current versions

* dev : v0.13
* staging : v0.13
* prod. : v0.11

---

## Installation

### Ruby version

2.4.1

### Rails version

5.0.3

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

### v0.13 (WorkShop)

* Workshops:
    * Event: pure/workshop differentiation (model, form, local.)
    * routes & controller, admin views
    * Front style (event variation)
    * API/front index scope selection
* Events:
    * Gallery: change filter scope (:end_at instead of :start_time)
* Admin:
    * Resource: error on destruction (item with dependencies)
    * Article, Page, Event: error on destruction (item linked to a home slide)
* Recette:
    * fix admin list imageless preview item

### v0.11 (Fixed Openning messages)

* OpeningMessages:
    * active default day message
    * day of the Week & TimeZone
* Event:
    * Front event page: style, center artist image in mask
    * Gallery: [R] change `#month_selector` marge & svg preserveAspectRatio attribute
* Recette:
    * fix home with imageless news


### v0.10 (Events gallery)

* EventsGallery: 
    * routes & controller
    * gallery & event_card integration
    * API: `GET /api/events` for async. loading/filters
    * InfiniteScroll: implementation (12/page)
    * filters by category/month/focus
* Focus: current method
* Event:
    * in_month method
    * add `place` attribute
    * `display_date` management
* WeezEvent:
    * improve date definition
    * admin: improve menu & links

### v0.9+

Temporary prod. deployment waiting v0.10

### v0.9 (WeezEvent, Focus, Event, Artist, Partner)

* WeezEvent
    * create model, controllers & abilities
    * controller, list & delete (views & methods)
    * waitting/getting page
    * API connection & endpoints implementation
    * iframe genration
* Focus
    * create model, controllers & abilities
    * admin views (list, details & forms pages)
    * Focus <> Article association link
* Event
    * create model, controllers & abilities
    * admin views (list, details & forms pages)
    * Front page integration
    * auto-load from WeezEvent
    * colored pages (inc. picture mask)
    * artists management
    * partners management
* Artist
    * create model, controllers & abilities
    * admin views (list, details & forms pages)
    * Artist<>Event link
    * Event's section integration (inc. modal & slider)
* Partner
    * create model, controllers & abilities
    * admin views (list, details & forms pages)
    * Partner<>Event link
* Home
    * ability to add Event to carrousel
* Admin:
    * menu reorganization
    * links to WeezEvents site
    * collapsable form (style & JS)
    * Associations: remove delete links on details pages
* ApplicationHelper:
    * `body_data` method
* Global:
    * update to Ruby 2.4.1
    * update to Rails 5.0.2
    * SVG to data method (for CSS inclusion)
    * Klox migration

### v0.5.1 (RC)

* RC:
    * active home
    * improve routes redirections
* TradeSpotting:
    * add pixels to app layout & styles
    * admin pixel management
    * page & article validations
* Helper: `active_links_to` method
    * Menu/Footer: implement active_links
* Recette:
    * fix carousel indicators vs. menu z-index
* Global Style:
    * menu: doesn't break links

### v0.5 (Home)

* Home:
    * integration (carousel)
    * create `HomeCarouselLink` model
    * admin: home & carousel links managements (to Page or Article for now)
    * admin: carousel slide preview
* Page/Article:
    * improve URL generation
    * style improvements (break too long word, URL)
    * add article tag
* ImageShip (gallries): improve auto-ranking consistency
* Menu & Footer:
    * add countdown (to 2017/04/29)
    * add Ⓜ in footer
* Global:
    * basic 404 page
    * Style: hide horizontal overflow (mobile contained view)
* SSL (https) : generate Lets Encryot certificate (Heroku), and active protocol

### v0.4 (Articles)

* Articles
    * create model, controllers & abilities
    * model's methods (page_url, facebook_url, ect.)
    * admin views (list, details, form)
    * front integration
* MediaLinks
* Menu & Footer:
    * integration
    * responsive menu (mobile burger/slider vs. desktop fixe one)
    * slide/swipe animation
    * patch bootstrap/swipe conflict with JS `reInitBootStrap()`
* Admin:
    * Resources details page: add galleries & pages association
* Recette:
    * Pages: admin: index, fix details & delete link
    * SVG: add stretching abilities
    * Admin: table view improvements

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
