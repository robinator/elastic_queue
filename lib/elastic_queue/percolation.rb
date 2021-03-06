module ElasticQueue
  module Percolation
    extend ActiveSupport::Concern

    module ClassMethods
      def percolator_queries
        queries = {}
        search = search_client.search index: '_percolator', body: { query: { match_all: {} } }, size: 1000
        search['hits']['hits'].each { |hit| queries[hit['_id']] = hit['_source'] }
        queries
      end

      def reverse_search(model)
        percolation = search_client.percolate index: index_name, body: { doc: model.indexed_for_queue }
        percolation['matches']
      end

      def unregister_percolator_query(name)
        search_client.delete index: '_percolator', type: index_name, id: name
      end

      def register_percolator_query(name, body)
        search_client.index index: '_percolator', type: index_name, id: name, body: body
      end

      def dynamically_percolate(model, percolator_body)
        search_id = SecureRandom.uuid
        # create a dynamic percolator with the query params, index our model in it and see if there are any matches
        search_client.index index: '_percolator', type: 'dynamic_percolator', id: search_id, body: percolator_body, refresh: true
        search = search_client.percolate index: 'dynamic_percolator', body: { doc: model.indexed_for_queue, query: { term: { _id: search_id } } }
        search_client.delete index: '_percolator', type: 'dynamic_percolator', id: search_id
        search
      end
    end

    def in_queue?(model)
      search = self.class.dynamically_percolate(model, @query.percolator_body)
      search['matches'].length == 1
    end

    def register_as_percolator_query(name)
      self.class.register_percolator_query(name, @query.percolator_body)
    end
  end
end