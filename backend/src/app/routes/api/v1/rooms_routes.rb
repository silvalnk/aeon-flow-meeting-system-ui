# frozen_string_literal: true

require_relative '../../../actions/create_room_action'
require_relative '../../../actions/list_rooms_action'
require_relative '../../../actions/get_room_action'
require_relative '../../../actions/update_room_action'
require_relative '../../../actions/delete_room_action'
require_relative '../../../actions/list_reservations_action'
require_relative '../../../actions/create_reservation_action'
require_relative '../../../actions/get_reservation_action'
require_relative '../../../actions/update_reservation_action'
require_relative '../../../actions/cancel_reservation_action'
require_relative '../../../../lib/shared_domain/web/routes'

module App
  module Routes
    module API
      module V1
        module RoomsRoutes
          include SharedDomain::Web::Routes

          module_function

          def register(app)
            app.get '/api/v1/reservations' do
              result = App::Actions::ListReservationsAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.get '/api/v1/rooms' do
              result = App::Actions::ListRoomsAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.post '/api/v1/rooms' do
              result = App::Actions::CreateRoomAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.get '/api/v1/rooms/:id' do
              result = App::Actions::GetRoomAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.put '/api/v1/rooms/:id' do
              result = App::Actions::UpdateRoomAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.delete '/api/v1/rooms/:id' do
              result = App::Actions::DeleteRoomAction.new.call(params)
              status result[:status]
              halt 204 if result[:status] == 204

              json(result[:body])
            end

            app.get '/api/v1/rooms/:room_id/reservations' do
              result = App::Actions::ListReservationsAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.post '/api/v1/rooms/:room_id/reservations' do
              result = App::Actions::CreateReservationAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.get '/api/v1/rooms/:room_id/reservations/:id' do
              result = App::Actions::GetReservationAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.put '/api/v1/rooms/:room_id/reservations/:id' do
              result = App::Actions::UpdateReservationAction.new.call(params)
              status result[:status]
              json(result[:body])
            end

            app.delete '/api/v1/rooms/:room_id/reservations/:id' do
              result = App::Actions::CancelReservationAction.new.call(params)
              status result[:status]
              halt 204 if result[:status] == 204

              json(result[:body])
            end
          end
        end
      end
    end
  end
end
