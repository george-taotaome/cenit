module Forms
  class JsonDataImport
    include DataImportCommon

    attr_reader :json_data

    validate do
      if errors.blank?
        @json_data, attr =
          if file.present?
            content = file.read rescue nil
            [content, :file]
          else
            [data.to_s, :data]
          end
        if decompress_content
          @json_data[0] = Zi
        end
        @json_data = @json_data && JSON.parse(@json_data) rescue nil
        if @json_data.is_a?(Hash)
          @json_data = [@json_data]
        else
          unless @json_data.is_a?(Array) && @json_data.all? { |item| item.is_a?(Hash) }
            errors.add(attr, 'contains not valid JSON data')
          end
        end
      end
    end

    rails_admin do
      visible false
      register_instance_option(:discard_submit_buttons) { true }
      edit do
        field :file do
          render do
            bindings[:form].file_field(self.name, self.html_attributes.reverse_merge(data: { fileupload: true }))
          end
        end
        field :data, :text do
          html_attributes do
            { cols: '74', rows: '15' }
          end
        end
      end
    end
  end
end
