# frozen_string_literal: true

module Super
  class Pagination
    include Enumerable

    attr_reader :current_pageno
    attr_reader :limit

    def initialize(total_count:, limit:, query_params:, page_query_param:)
      @total_count = total_count.to_i
      @limit = limit.to_i
      @query_params = query_params
      @page_query_param = page_query_param

      self.current_pageno = query_params[page_query_param]
    end

    def offset
      limit * (current_pageno - 1)
    end

    def current_pageno=(pageno)
      pageno = pageno.to_i

      @current_pageno =
        if pageno.zero?
          1
        else
          pageno
        end
    end

    def necessary?
      pages > 1
    end

    def each
      if !block_given?
        return enum_for(:each)
      end

      (1..pages).each do |pageno|
        is_current_page = pageno == current_pageno
        display = pageno.to_s
        page_query_params = @query_params.dup
        if pageno == 1
          page_query_params.delete(:page)
        else
          page_query_params[@page_query_param] = pageno
        end

        yield(page_query_params, is_current_page, display)
      end
    end

    def to_partial_path
      "pagination"
    end

    private

    def pages
      @pages ||=
        begin
          quotient, remainder = @total_count.divmod(@limit)

          if remainder.zero?
            quotient
          else
            quotient + 1
          end
        end
    end

    module ControllerMethods
      def index
        super
        @pagination = controls.initialize_pagination(action: current_action, records: @records, query_params: request.GET)
        @records = controls.paginate_records(action: current_action, records: @records, pagination: @pagination)
        @view.mains.first.parts.push(:@pagination)
      end
    end
  end
end
