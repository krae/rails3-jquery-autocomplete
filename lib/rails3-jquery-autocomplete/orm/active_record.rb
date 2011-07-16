module Rails3JQueryAutocomplete
  module Orm
    module ActiveRecord
      def get_autocomplete_order(method, options, model=nil)
        order = options[:order]

        table_prefix = model ? "#{model.table_name}." : ""
        order || "#{table_prefix}#{method} ASC"
      end

      def get_autocomplete_items(parameters)
        model   = parameters[:model]
        term    = parameters[:term]
        methods  = parameters[:methods]
        options = parameters[:options]
        scopes  = Array(options[:scopes])
        limit   = get_autocomplete_limit(options)
        order   = get_autocomplete_order(methods[0], options, model)

        items = model.scoped

        scopes.each { |scope| items = items.send(scope) } unless scopes.empty?

        items = items.select(get_autocomplete_select_clause(model, methods, options)) unless options[:full_model]
        items = items.where(get_autocomplete_where_clause(model, term, methods, options)).
            limit(limit).order(order)
      end

      def get_autocomplete_select_clause(model, methods, options)
        table_name = model.table_name
        ary = ["#{table_name}.#{model.primary_key}"]
        methods.each do |method|
          ary << "#{table_name}.#{method}"
        end
        (ary + (options[:extra_data].blank? ? [] : options[:extra_data]))
      end

      def get_autocomplete_where_clause(model, term, methods, options)
        table_name = model.table_name
        is_full_search = options[:full]
        like_clause = (postgres? ? 'ILIKE' : 'LIKE')
        str = ""
        ary = []
        methods.each do |method|
          str += " LOWER(#{table_name}.#{method}) #{like_clause} ? OR "
          ary << "#{(is_full_search ? '%' : '')}#{term.downcase}%"
        end
        [str[0..str.length-4]] + ary
      end

      def postgres?
        defined?(PGConn)
      end
    end
  end
end
