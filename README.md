# Tamale

*Hot* Tamale is a DSL for generating HTML.

## Usage

```ruby
model = {
  title: 'Home Page',
  items: [:one, :two, :three]
}

Tamale.define(:app) { |model|
  div(id: 'app') {
    h1 { text model.title }

    ul {
      model.items.each { |item|
        li { text item }
      }
    }
  }
}

Tamale.render(:app, model)
```
