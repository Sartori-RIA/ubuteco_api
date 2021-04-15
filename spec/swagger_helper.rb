# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_format = :yaml
  config.swagger_docs = {
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
          errors_object: {
            type: :object,
            properties: {
              errors: { '$ref' => '#/components/schemas/errors_map' }
            }
          },
          errors_map: {
            type: :object,
            additionalProperties: {
              type: :array,
              items: { type: :string }
            }
          },
          beers: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/beer'
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
              maker: { '$ref' => '#/components/schemas/maker' },
              beer_style: { '$ref' => '#/components/schemas/beer_style' },
              image: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[name quantity_stock price_cents price_currency maker_id beer_style_id image]
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
              '$ref' => '#/components/schemas/beer_styles'
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
            type: :array,
            items: {
              '$ref' => '#/components/schemas/dish'
            }
          },
          dish: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              price: { type: :number },
              dish_ingredients: {
                '$ref' => '#/components/schemas/dish_ingredients'
              },
              image: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id name price image]
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
              food: { '$ref' => '#/components/schemas/food' },
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
            type: :array,
            items: {
              '$ref' => '#/components/schemas/drink'
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
              maker_id: { type: :integer },
              maker: { '$ref' => '#/components/schemas/maker' },
              image: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id name quantity_stock price_cents price_currency maker_id maker image]
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
            type: :array,
            items: {
              '$ref' => '#/components/schemas/food'
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
              image: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id name quantity_stock valid_until price_cents price_currency image]
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
            type: :array,
            items: {
              '$ref' => '#/components/schemas/maker'
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
            type: :array,
            items: {
              '$ref' => '#/components/schemas/order'
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
                oneOf: [
                  { '$ref' => '#/components/schemas/drink' },
                  { '$ref' => '#/components/schemas/wine' },
                  { '$ref' => '#/components/schemas/beer' },
                  { '$ref' => '#/components/schemas/dish' },
                ]
              },
              item_type: {type: :string},
              quantity: {type: :integer},
              status: { type: :string }
            },
            required: %w[id item item_id item_type quantity_stock status]
          },
          new_order_item: {
            type: :object,
            properties: {
              item_id: {type: :integer},
              item_type: {type: :string},
              quantity: {type: :integer},
            },
            required: %w[item_id item_type quantity]
          },
          organizations: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/organization'
            }
          },
          organization: {
            type: :object,
            properties: {
              id: { type: :integer },
              logo: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id logo]
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
          themes: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/theme'
            }
          },
          theme: {
            type: :object,
            properties: {
              id: { type: :integer },
            },
            required: %w[id]
          },
          users: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/user'
            }
          },
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              avatar: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id avatar]
          },
          new_user: {
            type: :object,
            properties: {
            },
            required: %w[]
          },
          wines: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/wine'
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
              wine_style_id: { type: :integer },
              maker: { '$ref' => '#/components/schemas/maker' },
              wine_style: { '$ref' => '#/components/schemas/wine_style' },
              image: { '$ref' => '#/components/schemas/s3_image' }
            },
            required: %w[id name quantity_stock price_cents price_currency maker_id maker wine_style wine_style_id image]
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
          },
          s3_image: {
            type: :object,
            properties: {
              url: { type: :string },
              thumb: {
                type: :object,
                properties: {
                  url: { type: :string },
                },
                required: %w[url]
              }
            },
            required: %w[url]
          }
        }
      }
    }
  }
end
