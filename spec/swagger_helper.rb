# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s
  config.openapi_format = :yaml
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      consumes: ['application/json'],
      produces: ['application/json'],
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            description: 'JWT key necessary to use API calls',
            name: 'Authorization',
            in: :header
          }
        },
        schemas: {
          pagination_meta: {
            type: :object,
            properties: {
              page: { type: :integer },
              count: { type: :integer },
              pages: { type: :integer },
              previous: { type: [:integer, :null] },
              last: { type: :integer }
            }
          },
          errors_object: {
            type: :array,
            items: { type: :string }
          },
          beers: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/beer'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          beer: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              quantity: { type: :integer },
              price_cents: { type: :integer },
              price_currency: { type: :string },
              maker_id: { type: :integer },
              beer_style_id: { type: :integer },
              image_url: { type: :string },
              maker: { '$ref' => '#/components/schemas/maker' },
              beer_style: { '$ref' => '#/components/schemas/beer_style' },
            },
            required: %w[name quantity_stock price_cents price_currency maker_id beer_style_id]
          },
          new_beer: {
            type: :object,
            properties: {
              name: { type: :string },
              quantity: { type: :integer },
              price: { type: :number },
              maker_id: { type: :integer },
              beer_style_id: { type: :integer },
            },
            required: %w[name quantity_stock price maker_id beer_style_id]
          },
          beer_styles: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/beer_style'
            }
          },
          beer_style: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string }
            },
            required: %w[id name]
          },
          new_beer_style: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: %w[name]
          },
          dishes: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/dish'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          dish: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              price_cents: { type: :number },
              price_currency: { type: :string },
              image_url: { type: :string },
              dish_ingredients: { '$ref' => '#/components/schemas/dish_ingredients' },
            },
            required: %w[id name price_cents price_currency]
          },
          edit_dish: {
            type: :object,
            properties: {
              name: { type: :string },
              price: { type: :number },
              dish_ingredients_attributes: {
                '$ref' => '#/components/schemas/edit_dish_ingredients'
              },
            },
            required: %w[name price]
          },
          new_dish: {
            type: :object,
            properties: {
              name: { type: :string },
              price: { type: :number },
              dish_ingredients_attributes: {
                '$ref' => '#/components/schemas/new_dish_ingredients'
              },
            },
            required: %w[name price]
          },
          new_dish_ingredients: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/new_dish_ingredient'
            }
          },
          edit_dish_ingredients: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/edit_dish_ingredient'
            }
          },
          dish_ingredients: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/dish_ingredient'
            }
          },
          edit_dish_ingredient: {
            type: :object,
            properties: {
              id: { type: :integer },
              food_id: { type: :integer },
              quantity: { type: :integer }
            },
            required: %w[food food_id quantity]
          },
          dish_ingredient: {
            type: :object,
            properties: {
              id: { type: :integer },
              food: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                }
              },
              food_id: { type: :integer },
              quantity: { type: :integer }
            },
            required: %w[id food food_id quantity]
          },
          new_dish_ingredient: {
            type: :object,
            properties: {
              food_id: { type: :integer },
              quantity: { type: :integer }
            },
            required: %w[food_id quantity]
          },
          drinks: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/drink'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          drink: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              quantity: { type: :integer },
              price_cents: { type: :integer },
              price_currency: { type: :string },
              image_url: { type: :string},
              maker_id: { type: :integer },
              maker: { '$ref' => '#/components/schemas/maker' },
            },
            required: %w[id name quantity_stock price_cents price_currency]
          },
          new_drink: {
            type: :object,
            properties: {
              name: { type: :string },
              quantity: { type: :integer },
              price: { type: :number },
              price_currency: { type: :string },
              maker_id: { type: :integer },
            },
            required: %w[name quantity_stock price price_currency maker_id]
          },
          foods: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/food'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          food: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              quantity_stock: { type: :integer },
              valid_until: { type: :string },
              price_cents: { type: :integer },
              price_currency: { type: :string },
              image_url: { type: :string }
            },
            required: %w[id name quantity_stock valid_until price_cents price_currency]
          },
          new_food: {
            type: :object,
            properties: {
              name: { type: :string },
              quantity_stock: { type: :integer },
              valid_until: { type: :string },
              price: { type: :number },
            },
            required: %w[name quantity_stock valid_until price]
          },
          makers: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/maker'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          maker: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              country: { type: :string },
            },
            required: %w[id name country]
          },
          new_maker: {
            type: :object,
            properties: {
              name: { type: :string },
              country: { type: :string },
            },
            required: %w[name country]
          },
          orders: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/order'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          order: {
            type: :object,
            properties: {
              id: { type: :integer },
            },
            required: %w[id]
          },
          new_order: {
            type: :object,
            properties: {
            },
            required: %w[]
          },
          order_items: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/order_item'
            }
          },
          order_item: {
            type: :object,
            properties: {
              id: { type: :integer },
              item: {
                anyOf: [
                  { '$ref' => '#/components/schemas/drink' },
                  { '$ref' => '#/components/schemas/wine' },
                  { '$ref' => '#/components/schemas/beer' },
                  { '$ref' => '#/components/schemas/dish' },
                ]
              },
              item_type: { type: :string },
              quantity: { type: :integer },
              status: { type: :string }
            },
            required: %w[id item item_id item_type quantity status]
          },
          new_order_item: {
            type: :object,
            properties: {
              item: {
                anyOf: [
                  { '$ref' => '#/components/schemas/drink' },
                  { '$ref' => '#/components/schemas/wine' },
                  { '$ref' => '#/components/schemas/beer' },
                  { '$ref' => '#/components/schemas/dish' },
                ]
              },
              item_id: { type: :integer },
              item_type: { type: :string },
              quantity: { type: :integer },
            },
            required: %w[item_id item_type quantity]
          },
          kitchen_items: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/kitchen_item'
            }
          },
          kitchen_item: {
            type: :object,
            properties: {
              id: { type: :integer },
              table: { '$ref' => '#/components/schemas/table' },
              order_item: { '$ref' => '#/components/schemas/dish' },
              status: { type: :string },
            },
            required: %w[id status]
          },
          organizations: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/organization'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          organization: {
            type: :object,
            properties: {
              id: { type: :integer },
              logo_url: { type: :string },
              locale: { type: :string },
              default_currency: { type: :string },
              timezone: { type: :string }
            },
            required: %w[id]
          },
          new_organization: {
            type: :object,
            properties: {
            },
            required: %w[]
          },
          roles: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/role'
            }
          },
          role: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
            },
            required: %w[id name]
          },
          new_role: {
            type: :object,
            properties: {
              name: { type: :string },
            },
            required: %w[name]
          },
          tables: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/table'
            }
          },
          table: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              chairs: { type: :integer },
            },
            required: %w[id name chairs]
          },
          new_table: {
            type: :object,
            properties: {
              name: { type: :string },
              chairs: { type: :integer },
            },
            required: %w[name chairs]
          },
          users: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/user'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              email: { type: :string },
              avatar_url: { type: :string }
            },
            required: %w[id name]
          },
          new_user: {
            type: :object,
            properties: {
            },
            required: %w[]
          },
          wines: {
            type: :object,
            required: %w[meta data],
            properties: {
              data: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/wine'
                }
              },
              meta: {
                '$ref' => '#/components/schemas/pagination_meta'
              }
            }
          },
          wine: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              quantity: { type: :integer },
              price_cents: { type: :integer },
              price_currency: { type: :string },
              maker_id: { type: :integer },
              image_url: { type: :string },
              wine_style_id: { type: :integer },
              maker: { '$ref' => '#/components/schemas/maker' },
              wine_style: { '$ref' => '#/components/schemas/wine_style' },
            },
            required: %w[id name quantity_stock price_cents price_currency maker_id maker wine_style wine_style_id]
          },
          new_wine: {
            type: :object,
            properties: {
              name: { type: :string },
              quantity: { type: :integer },
              price: { type: :integer },
              maker_id: { type: :integer },
              wine_style_id: { type: :integer },
            },
            required: %w[name quantity_stock price maker_id wine_style_id]
          },
          wine_styles: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/wine_style'
            }
          },
          wine_style: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
            },
            required: %w[id name]
          },
          new_wine_style: {
            type: :object,
            properties: {
              name: { type: :string },
            },
            required: %w[name]
          }
        }
      }
    }
  }
end