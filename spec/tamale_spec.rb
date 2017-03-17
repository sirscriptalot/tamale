require          'minitest/autorun'
require_relative '../lib/tamale'

describe 'Tamale#render' do
  before do
    @template = Tamale.new { |left, right|
      text "#{left}#{right}"
    }
  end

  it 'calls template with arguments' do
    assert_equal('foobar', @template.render('foo', 'bar'))
  end
end

describe 'Text elements' do
  before do
    @template = Tamale.new { |value|
      div { text 'simple' }
    }
  end

  it 'renders an html string' do
    assert_equal('<div>simple</div>', @template.render)
  end
end

describe 'Nested elements' do
  before do
    @template = Tamale.new {
      ul {
        li { text 'one' }
        li { text 'two' }
      }
    }
  end

  it 'renders in proper context' do
    assert_equal('<ul><li>one</li><li>two</li></ul>', @template.render)
  end
end

describe 'Multinested elements' do
  before do
    @template = Tamale.new {
      ul {
        li {
          text 'one'; text 'two'
        }
      }
    }
  end

  it 'renders in proper context' do
    assert_equal('<ul><li>onetwo</li></ul>', @template.render)
  end
end

describe 'Void elements' do
  before do
    @template = Tamale.new {
      div {
        input(type: 'text')
      }
    }
  end

  it 'never prints a closing tag' do
    assert_equal('<div><input type="text" /></div>', @template.render)
  end
end

describe 'Normal elements' do
  before do
    @template = Tamale.new {
      div { div }
    }
  end

  it 'always prints a closing tag' do
    assert_equal('<div><div></div></div>', @template.render)
  end
end
