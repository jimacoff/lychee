RSpec::Matchers.define :exceed_query_limit do |expected|
  supports_block_expectations

  match do |bl|
    record_queries(&bl)
    @queries.length > expected
  end

  failure_message do
    "expected: #{expected} queries min\nactual: #{@queries.length} queries" \
      "\n\n#{query_info_text}"
  end

  failure_message_when_negated do
    "expected: #{expected} queries max\nactual: #{@queries.length} queries" \
      "\n\n#{query_info_text}"
  end

  def record_queries
    @queries = []

    ActiveSupport::Notifications
      .subscribed(method(:record_query), 'sql.active_record') { yield }
  end

  def record_query(_name, _start, _finish, _id, payload)
    root_path = Rails.root.to_path
    vendor_path = Rails.root.join('vendor').to_path

    line = caller.find do |c|
      c.start_with?(root_path) && !c.start_with?(vendor_path)
    end
    @queries << [payload[:sql], line]
  end

  def query_info_text
    @queries.map { |(query, line)| "#{query}\n\t#{line}" }.join("\n\n")
  end
end
