require 'spec_helper'
require 'messages/service_bindings_list_message'

module VCAP::CloudController
  describe ServiceBindingsListMessage do
    describe '.from_params' do
      let(:params) do
        {
          'page'      => 1,
          'per_page'  => 5,
          'order_by'  => 'created_at'
        }
      end

      it 'returns the correct AppCreateMessage' do
        message = ServiceBindingsListMessage.from_params(params)

        expect(message).to be_a(ServiceBindingsListMessage)
        expect(message.page).to eq(1)
        expect(message.per_page).to eq(5)
        expect(message.order_by).to eq('created_at')
      end

      it 'converts requested keys to symbols' do
        message = ServiceBindingsListMessage.from_params(params)

        expect(message.requested?(:page)).to be_truthy
        expect(message.requested?(:per_page)).to be_truthy
        expect(message.requested?(:order_by)).to be_truthy
      end
    end

    describe 'fields' do
      it 'accepts a set of fields' do
        message = ServiceBindingsListMessage.new({
            page: 1,
            per_page: 5,
            order_by: 'created_at',
          })
        expect(message).to be_valid
      end

      it 'accepts an empty set' do
        message = ServiceBindingsListMessage.new
        expect(message).to be_valid
      end

      it 'does not accept a field not in this set' do
        message = ServiceBindingsListMessage.new({ foobar: 'pants' })

        expect(message).not_to be_valid
        expect(message.errors[:base]).to include("Unknown query parameter(s): 'foobar'")
      end

      describe 'validations' do
        it_behaves_like 'a page validator'
        it_behaves_like 'a per_page validator'

        describe 'order_by' do
          describe 'valid values' do
            it 'created_at' do
              message = ServiceBindingsListMessage.new order_by: 'created_at'
              expect(message).to be_valid
            end

            it 'updated_at' do
              message = ServiceBindingsListMessage.new order_by: 'updated_at'
              expect(message).to be_valid
            end

            describe 'order direction' do
              it 'accepts valid values prefixed with "-"' do
                message = ServiceBindingsListMessage.new order_by: '-updated_at'
                expect(message).to be_valid
              end

              it 'accepts valid values prefixed with "+"' do
                message = ServiceBindingsListMessage.new order_by: '+updated_at'
                expect(message).to be_valid
              end
            end
          end

          it 'is invalid otherwise' do
            message = ServiceBindingsListMessage.new order_by: '+foobar'
            expect(message).to be_invalid
            expect(message.errors[:order_by].length).to eq 1
          end
        end
      end
    end
  end
end
