module WithKeyAssignmentProcessor
  def with_key_assignment_processor
    raise "Missing block" unless block_given?

    thread = Thread.new do
      Munificent::KeyAssignment::RequestProcessor.start
    end

    Munificent::KeyAssignment::RequestProcessor.ping_processor!

    yield
  ensure
    thread.kill
    Munificent::KeyAssignment::RequestProcessor.clear_all_queues
  end
end
