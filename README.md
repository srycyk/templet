
# Templet

## Introduction

This gem is a stand-alone feather-weight DSL in pure Ruby
that renders HTML via method calls.

It can run from anywhere (within reason), and with next to no set up.
Also, it won't cause installation conflicts,
as it has no external run-time dependencies.

For example, it may be used with a framework (like Rails or Sinatra),
or as part of a static site generator, or inside a command line script.

It has three main sections:

1. A basic (in-line) renderer.

2. Base classes for splitting up a view into separate components.

3. Helper methods for rendering HTML tables and lists.

_Incidentally, and if such a need arises,
there is another renderer class, *Templet::Renderers::ERb*,
that you may use to insert markup inside of a main ERb layout,
either on file or as a string._

## The basic DSL (Renderer)

The DSL processing (i.e. HTML rendering) is handled by
the class, *Templet::Renderer*.
But don't expect anything earth-shattering,
as this class breaks no new ground.
It's as simple a DSL as you're likely to come across.
Also, there are a good few others that are similar,
e.g. XML Builder, Markaby, Arbre, and Fortitude.

The DSL allows you to pass in local variables,
as well as multiple contexts for method look-ups,
which means that the DSL is able to expose a wide range of methods
that can be called from the markup code directly.

However, this basic Renderer, when used by itself,
has no in-built functionality for modularity,
and so is not really suitable for long HTML pages,
or for handling variation, or for code sharing.

## Components (Layouts and Partials)

To avoid these limitations, there are, in addition,
two base classes supplied that can be used as building blocks
for composing view segments.

They ought to be used in preference to the (above mentioned)
*Renderer* class, which they use internally.
The *Renderer* provides the context in which these Components are run.

The two classes, whose API's have just a single *call* method, are:

1. *Templet::Component::Layout*

2. *Templet::Component::Partial*

In most cases they are to be used as superclasses,
from which your own custom components (as subclasses) inherit.

You begin with a single *Layout*, which, typically,
contains calls to a number of *Partials*,
maybe interspersed with some markup code.

Using these as base classes,
your own subclasses can receive (local) input variables,
encapsulate helper methods,
and act as a container for constituent elements.

More specifically,
these classes allow you to develop general-purpose components,
such as, HTML layouts, Rails forms, Bootstrap menus,
and even a full-blown Rails Scaffolding alternative.

But there's no need for you to embark on such a venture yourself,
as these things are implemented in the related gem:
[templet\_rails](https://github.com/srycyk/templet_rails).

> There is a third kind of component, *Templet::Component::Template*
> that renders an auxiliary ERb template, _(like a Rails partial)_.
> However, this experimental feature is inefficient and, besides,
> it merely regurgitates existing functionality that this gem
> sets out to replace!
> Having said this, there may be some *corner* cases where using this
> kind of Component will make sense.
> _This Component isn't explained here, but the tests outline usage._

## HTML Helpers

Some further classes are included (in the *templet/html/* sub-directory),
that provide a short-hand way to render HTML lists and tables.
A stardard HTML list is generated from a given Ruby Array, similarly,
an HTML table (or definition list) is generated from a Ruby Hash.

Examples of using these are given towards the end.

## Renderer Usage

Except for very small jobs,
it's best not to construct an instance of a *Renderer* explicitly,
even though this is illustrated in the examples which follow.

As noted, it's neater to use the *Renderer* implicitly,
that is, by means of a *Layout* containing a number of *Partials*,
which both contain an instance of a *Renderer*.

Still, it is useful to have a grounding in the basic rules and techniques,
as they apply to the Components as well.

### Rudimentary Renderer Usage

No need to begin by reading an API,
_(anyway, there isn't one - but most classes just have a **call** method),_
as this example shows elementary usage:

```ruby
require 'templet/renderer'

  message = 'Hello there'

  html = Templet::Renderer.new.call do
           header = head { title 'Role' }

           # +message+ is the closure variable above
           content = p { message }

           # The Renderer only shows what a block returns
           # which should be a string, or a callable that returns a string
           # To return multiple values, use an array of such
           html { [ header, body(content) ] }
         end

  puts html
```

This produces the following HTML:

```html
<html><head><title>Role</title>
</head>

<body><p>Hello there</p>
</body>
</html>
```

> Note that the code blocks (passed to the *Renderer*)
> are not run in the lexical context that blocks normally are.
> The blocks are actually executed inside of an instance of *Renderer*
> which inherits from *BasicObject* -
> which is a threadbare class of very few methods.
> It's up to you to provide the lookup context(s),
> which are passed into the *Renderer's* constructor.

### More Advanced Renderer Usage

The following example explains more
and covers a lot to do with visibility and scoping:

```ruby
require 'templet'

  class Lister
    def items
      %w(One Two Three)
    end
  end

  def content
    'Some content'
  end

  col_tag = Templet::Renderers::Tag.new(:div, class: :col_md_4)

  # The first two arguments are contexts for method lookups
  #
  # The final argument list local variables which take precedence
  #
  # The block renders the markup
  # Note the shortcut call, this call is stated in full in the above example
  html = Templet.(self, Lister.new, title: 'A Title') do
           more_content = 'More content'

           # +title+ is (in effect) a local variable passed into the constructor
           [ -> { h1(title, :strong) }, # you can include anything callable

             # Calls +items+ from Lister instance, given as a constructor argument
             # The +_p+ call renders a <p> tag
             #   without the underscore the Kernel#p method would override
             _p(ul(:list_unstyled) { items.map {|item| li item } }),

             div(:row) do
               # Calls +content+ because +self+ is passed into the constructor
               # +col_tag+ is a closure variable defined above
               [ col_tag.(content), col_tag.(more_content), col_tag.('...') 
]
             end
           ]
         end

  puts html
```

This produces the following HTML:

```html
<h1 class='strong'>A Title</h1>

<p><ul class='list-unstyled'><li>One</li>

<li>Two</li>

<li>Three</li>
</ul>
</p>

<div class='row'><div class='col-md-4'>Some content</div>

<div class='col-md-4'>More content</div>

<div class='col-md-4'>...</div>
</div>
```

## Notes on Usage

The main quirk is that the *Renderer* only outputs
the actual return value of a given block.
That is, statements preceding the very last one won't
show up in the resultant markup.
*This behaviour differs from that of most other markup API's.*

A block's return type must be either an array of strings or of *callable*
entities (which themselves return one or more strings).
This array can be nested at any depth.

Importantly, the block, passed to *Renderer#call*, is **not**
executed in its natural local (i.e. lexical) scope.
This means that, although local variables will be accessible,
the methods (within the current context) won't - unless the
current value of *self* is passed into the *Renderer's* constructor,
as one of the initial arguments.

*To put this in more practical terms: be aware that if an error does occur,
its origin may be flagrantly misreported in the stack trace.*

The tests have more examples of usage,
also, the source code is easy to follow and is commented.

But don't dig too deep.
There's not a lot you need to learn to get started,
and you should be able to pick up the rest as you go along.

## Components

As said, Components facilitate a modular (object oriented) approach
to rendering markup.

You begin with a Layout, consists of a number of Partials.

There is often no need to have more than a single Layout,
since Partials can be nested inside one another.

Together, they perform much the same function as their namesakes in Rails.

### Examples of a Layout with Partials

#### A Very Basic Layout Example

```ruby
require 'templet/component'

  html = Templet::Component::Layout.new(heading: 'A Title').call do
           # The method calls become HTML tags
           html do
             # +heading+ is passed by name above, it overrides
             [ head(title heading), body { div 'Hello' } ]
           end
         end

  puts html
```

This produces the following HTML:

```html
<html><head><title>A Title</title>
</head>

<body><div>Hello</div>
</body>
</html>
```

#### A Slightly More Realistic Example

```ruby
require 'templet/component'

class HtmlLayout < Templet::Component::Layout
  def call
    super do
      html do
        [ head { title heading },
          # The renderer is passed to calling block
          body(yield renderer) ]
      end
    end
  end
end

class BodyPart < Templet::Component::Partial
  def call
    super do
      span hello
    end
  end

  private

  def hello
    'Hello'
  end
end

class BodyBuild < Templet::Component::Partial
  def call
    # This is an alternative way to render markup, i.e. without a super call
    renderer.call { div BodyPart.new(renderer), :row }
  end
end

  html = HtmlLayout.new(heading: 'Down').call do |renderer|
           # No need to explicitly call(), this'll be done later on
           BodyBuild.new(renderer)
         end

  puts html
```

This produces the following HTML:

```html
<html><head><title>Down</title>
</head>

<body><div class='row'><span>Hello</span>
</div>
</body>
</html>
```

> Although this DSL relies heavily on *method_missing*,
> this has not brought poor performance - quite the reverse.
> After all, this DSL is tiny, and thus quick to load and run,
> making no calls to external libraries.
> In ERb, or HAML, the source code is parsed (byte by byte)
> so as to generate some new Ruby code, that is finally executed.

## Examples of Rendering HTML Composites

In these examples, a **nil** value is passed to the constructor,
but in application code, this will be, in nearly all cases,
replaced by an instance of a *Renderer*.

> To load these classes you must add: `require 'templet/html'`.

### An Unordered List

```ruby
Templet::Html::List.new(nil).(["One", "Two", "Three"])
```

This produces the following HTML:

```html
<ul><li>One</li>

<li>Two</li>

<li>Three</li>
</ul>
```

### A Definition List

In the most basic use, you pass in a Hash,
where the key is the title (the *dt* tag),
and the value is the data (the *dd* tag).
This is done as follows:

```ruby
Templet::Html::DefinitionList.new(nil).({"One"=>"First", "Two"=>"Second", "Three"=>"Third"})
```

This produces the following HTML:

```html
<dl><dt>One</dt>
<dd>First</dd>

<dt>Two</dt>
<dd>Second</dd>

<dt>Three</dt>
<dd>Third</dd>
</dl>
```

In addition, the value of an entry in this *control* Hash
can also be a Symbol or Proc.
In these cases you also supply a record, as a second parameter to *call*.
If a Symbol is given then it's used as a (Hash) key,
as in `record[key]`.
If a Proc is given then it's called with the
record passed as the first parameter, as in `func.call(record)`.
_Where *func* is the passed-in Proc_

```ruby
record = OpenStruct.new(field_1: 'Value 1', field_2: 'Value 2')

controls = { first: :field_1, second: -> (record) { record.send(:field_2) } }

Templet::Html::DefinitionList.new(nil).(controls, record, html_class: 'low')
```

This produces the following HTML:

```html
<dl class='low'><dt>First</dt>
<dd>Value 1</dd>

<dt>Second</dt>
<dd>Value 2</dd>
</dl>
```

### A Table

To render an HTML table you pass to the *call* method,
a control Hash (as set out for the Definition List just above),
and a list of records which, obviously, map to a table row.

```ruby
controls = { 'Title 1' => nil, # shows the whole of the 'numbers' hash
                               # if an array was given, it'd be indexed
             'Title 2' => 'Two', # shows the 'numbers' hash entry 'Two'
             # calls this proc - the first param is a Renderer instance
             'Title 3' => proc {|_, numbers| numbers['Three'] }
           }

Templet::Html::Table.new(nil).(controls, [{"One"=>"First", "Two"=>"Second", "Three"=>"Third"}])
```

This produces the following HTML:

```html
<table><thead><tr><th>Title 1</th>

<th>Title 2</th>

<th>Title 3</th>
</tr>
</thead>

<tbody><tr>{"One"=>"First", "Two"=>"Second", "Three"=>"Third"}
<td>Second</td>

<td>Third</td>
</tr>
</tbody>

<tfoot><tr><td colspan='3'></td>
</tr>
</tfoot>
</table>
```

## Examples of Rendering Tags

As mentioned, the *Renderer* class,
(via a block passed to its *call* method),
lets you render markup by direct Ruby method calls.

Here are a few examples of some of the ways of using the API to render tags:

* `span('Hello', :small, id: '999') => <span id='999' class='small'>Hello</span>`

* `__p(:pull_right) { 'Hello' } => <p class='pull-right'>Hello</p>`

* `div('', :pull_right, class: 'clearfix') => <div class='clearfix pull-right'></div>`

As you can see, an HTML class can be given as an argument.
Any underscores, in the class name, will be replaced
by dashes in the (generated) markup.

To avoid method name clashes, you can prefix a method call with a number of
underscores, and these won't appear in the corresponding tag name.
For example, this is particularly important when rendering the HTML tag *p*,
as there's a Ruby *Kernel* method called *p*, that may be called first.

If you prefer, you can call a *tag* helper method instead of
inferring a tag name from a method name. For example:

* `tag(:p, 'Hello', :pull_right) => <p class='pull-right'>Hello</p>`

Note that this method will mask any other method,
of the same name (i.e. *tag*), higher up in the inheritance hierarchy.

## Installation

Add this line to your application's Gemfile:

```ruby
    gem 'templet'
```

And then execute:

```
    $ bundle
```

Or install it yourself as:

```
    $ gem install templet
```

Or get it from Github at
[github.com/srycyk/templet](https://github.com/srycyk/templet).


## Licence

The gem is available as open source under the terms
of the [MIT License](https://opensource.org/licenses/MIT).

