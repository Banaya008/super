require "test_helper"
require "generators/super/resource/resource_generator"

class Super::ResourceGeneratorTest < Rails::Generators::TestCase
  tests Super::ResourceGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  def test_generator_creates_expected_files
    @original_configuration = Super.configuration
    Super.instance_variable_set(:@configuration, nil)
    Super.configuration do |c|
      c.controller_namespace = "badminton"
    end

    run_generator(["ship"])

    assert_file("app/controllers/badminton/ships_controller.rb", <<~RUBY)
      module Badminton
        class ShipsController < BadmintonController
          private

          def dashboard
            ShipDashboard.new
          end
        end
      end
    RUBY

    assert_file("app/super/ship_dashboard.rb")
  ensure
    Super.instance_variable_set(:@configuration, @original_configuration)
  end

  def test_generator_creates_expected_files_when_blank_namespace
    @original_configuration = Super.configuration
    Super.instance_variable_set(:@configuration, nil)
    Super.configuration do |c|
      c.controller_namespace = ""
    end

    run_generator(["ship"])

    assert_file("app/controllers/ships_controller.rb", <<~RUBY)
      class ShipsController < AdminController
        private

        def dashboard
          ShipDashboard.new
        end
      end
    RUBY

    assert_file("app/super/ship_dashboard.rb")
  ensure
    Super.instance_variable_set(:@configuration, @original_configuration)
  end

  def test_dashboard_looks_right
    run_generator(["ship"])

    assert_file("app/super/ship_dashboard.rb", <<~RUBY)
      class ShipDashboard
        def title
          Ship.name.pluralize
        end

        def model
          Ship
        end

        def index_scope
          Ship.all
        end

        def index_columns
          [
          ]
        end

        def create_scope
          Ship.all
        end

        def new_scope
          Ship.all
        end

        def new_columns
          [
          ]
        end

        def edit_scope
          Ship.all
        end

        def edit_columns
          [
          ]
        end

        def show_scope
          Ship.all
        end

        def show_columns
          [
          ]
        end

        def update_scope
          Ship.all
        end

        def destroy_scope
          Ship.all
        end

        def permitted_create_params(params)
          params.require(:ship).permit()
        end

        def permitted_update_params(params)
          params.require(:ship).permit()
        end
      end
    RUBY
  end
end
