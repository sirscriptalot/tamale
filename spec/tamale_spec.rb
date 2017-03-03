require          'minitest/autorun'
require_relative '../lib/tamale'

describe 'Tamale::define' do
  before do
    @template = ->() { text 'template' }

    Tamale.define(:foo, &@template)
  end

  it 'defines a template' do
    assert_equal(@template, Tamale.templates[:foo])
  end
end

describe 'Tamale::render' do
  before do
    Tamale.define(:foobar) { |left, right| text "#{left}#{right}" }
  end

  it 'calls template with arguments' do
    assert_equal('foobar', Tamale.render(:foobar, 'foo', 'bar'))
  end
end

describe 'Tamale :simple' do
  before do
    Tamale.define(:simple) do |value|
      div { text 'simple' }
    end
  end

  it 'renders an html string' do
    assert_equal('<div>simple</div>', Tamale.render(:simple))
  end
end

describe 'Tamale :nested' do
  before do
    Tamale.define(:nested) {
      ul {
        li { text 'one' }
        li { text 'two' }
      }
    }
  end

  it 'renders' do
    assert_equal('<ul><li>one</li><li>two</li></ul>', Tamale.render(:nested))
  end
end

describe 'Void elements' do
  before do
    Tamale.define(:void) {
      div {
        input(type: 'text')
      }
    }
  end

  it 'never prints a closing tag' do
    assert_equal('<div><input type="text" /></div>', Tamale.render(:void))
  end
end

describe 'Normal elements' do
  before do
    Tamale.define(:normal) {
      div { div { } }
    }
  end

  it 'always prints a closing tag' do
    assert_equal('<div><div></div></div>', Tamale.render(:normal))
  end
end
