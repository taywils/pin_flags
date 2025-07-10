class PinFlags::Page
  DEFAULT_PAGE_SIZE = 10

  attr_reader :records, :index, :page_size

  def initialize(relation, page: 1, page_size: DEFAULT_PAGE_SIZE)
    @relation = relation
    @page_size = page_size
    @index = [ page, 1 ].max
  end

  def records
    @relation.limit(page_size).offset(offset)
  end

  def first?
    index == 1
  end

  def last?
    index == pages_count || empty? || records.empty?
  end

  def empty?
    total_count == 0
  end

  def previous_index
    [ index - 1, 1 ].max
  end

  def next_index
    pages_count&.positive? ? [ index + 1, pages_count ].min : index + 1
  end

  def pages_count
    (total_count.to_f / page_size).ceil unless total_count.infinite?
  end

  def total_count
    @total_count ||= @relation.size # Uses loaded records if available, otherwise falls back to count
  end

  private
    def offset
      (index - 1) * page_size
    end
end
