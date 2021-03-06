require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase

  # Each request

  test 'increment total and status' do
    tags_1 = {
      controller: "HomeController",
      action: "index",
      format: "html"
    }.merge(default_tags)

    visit root_path

    assert_equal 1, counters.fetch("rails.request.total", tags: tags_1)[:value]
    assert_equal 1, counters.fetch("rails.request.status", tags: { status: 200 }.merge(default_tags))[:value]
    assert_equal 1, counters.fetch("rails.request.method", tags: { method: "get" }.merge(default_tags))[:value]

    visit root_path

    assert_equal 2, counters.fetch("rails.request.total", tags: tags_1)[:value]

    tags_2 = {
      controller: "StatusController",
      action: "index",
      format: "html"
    }.merge(default_tags)

    visit '/status/204'

    assert_equal 1, counters.fetch("rails.request.total", tags: tags_2)[:value]
    assert_equal 1, counters.fetch("rails.request.status", tags: { status: 204 }.merge(default_tags))[:value]
  end

  test 'request times' do
    tags = {
      controller: "HomeController",
      action: "index",
      format: "html"
    }.merge(default_tags)

    visit root_path

    # common for all paths
    assert_equal 1, aggregate.fetch("rails.request.time", tags: tags)[:count],
      'should record total time'
    assert_equal 1, aggregate.fetch("rails.request.time.db", tags: tags)[:count],
      'should record db time'
    assert_equal 1, aggregate.fetch("rails.request.time.view", tags: tags)[:count],
      'should record view time'

    # status specific
    assert_equal 1, aggregate.fetch("rails.request.status.time", tags: { status: 200 }.merge(default_tags))[:count]

    # http method specific
    assert_equal 1, aggregate.fetch("rails.request.method.time", tags: { method: "get" }.merge(default_tags))[:count]
  end

  test 'track slow requests' do
    tags = {
      controller: "HomeController",
      action: "slow",
      format: "html"
    }.merge(default_tags)

    visit slow_path
    assert_equal 1, counters.fetch("rails.request.slow", tags: tags)[:value]
  end

end
