json.partial! "api/makers/maker", maker: @maker
json.array! @makers, partial: "api/makers/maker", as: :maker
