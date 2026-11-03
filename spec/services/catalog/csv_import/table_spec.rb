# frozen_string_literal: true

require "rails_helper"

RSpec.describe Catalog::CsvImport::Table do
  def parse(text, type: "beer")
    described_class.parse(StringIO.new(text), product_type: type)
  end

  let(:header) { "name,price,ibu,abv,maker,beer_style" }

  it "reads comma and semicolon files, including a BOM" do
    comma = parse("#{header}\nA,12.50,15,4.8,Maker,Style\n")
    semi = parse("name;price;ibu;abv;maker;beer_style\nA;12,50;15;4,8;Maker;Style\n")
    bom = parse("\uFEFFname,price,ibu,abv,maker,beer_style\nA,1,2,3,M,S\n")

    expect(comma.rows.first).to include("name" => "A", "price" => "12.50", "line" => 2)
    expect(semi.rows.first).to include("price" => "12,50", "abv" => "4,8")
    expect(bom.rows.first["name"]).to eq("A")
  end

  it "rejects a Portuguese header before any product is built" do
    expect { parse("nome,preco,ibu,abv,fabricante,estilo\nA,1,2,3,M,S\n") }
      .to raise_error(Catalog::CsvImport::InvalidFile, /nome/)
  end

  it "rejects an empty file and a file over 500 data rows" do
    expect { parse("") }.to raise_error(Catalog::CsvImport::InvalidFile)
    body = ([header] + Array.new(501) { "A,1,2,3,M,S" }).join("\n")
    expect { parse(body) }.to raise_error(Catalog::CsvImport::InvalidFile)
  end

  it "parses each English template" do
    CatalogImport::PRODUCT_TYPES.each do |type|
      table = parse(Catalog::CsvImport::Columns.template_csv(type), type:)
      expect(table.rows.size).to eq(1)
    end
  end
end
