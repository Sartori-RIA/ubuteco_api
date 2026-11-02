# frozen_string_literal: true

require "rails_helper"

RSpec.describe Catalog::CsvImportJob do
  let(:organization) { create(:organization) }
  let(:maker) { create(:maker, organization:, name: "Lupulo") }
  let(:style) { create(:beer_style, name: "Ipa") }

  def enqueue(csv)
    import = organization.catalog_imports.create!(
      user: organization.user,
      product_type: "beer",
      status: "queued",
      total_rows: 2,
      enqueued_at: Time.current
    )
    import.file.attach(io: StringIO.new(csv), filename: "beers.csv", content_type: "text/csv")
    import
  end

  def beer_csv(second_style)
    <<~CSV
      name;price;ibu;abv;maker;beer_style
      First;12,50;20;4,5;#{maker.name};#{style.name}
      Second;12,50;20;4,5;#{maker.name};#{second_style}
    CSV
  end

  it "keeps the valid row, logs the failed line, and enqueues the mail" do
    import = enqueue(beer_csv("Missing"))

    expect { described_class.new.perform(import.id) }
      .to have_enqueued_mail(CatalogImportMailer, :finished)
      .and change(Beer, :count).by(1)

    import.reload
    failed = import.row_log.find { |entry| entry["status"] == "failed" }
    expect(import.status).to eq("completed")
    expect(import.failed_rows).to eq(1)
    expect(failed["line"]).to eq(3)
    expect(failed["errors"].join).to include("Missing")
    expect(import.file).not_to be_attached

    mail = CatalogImportMailer.with(import:).finished
    expect(mail.body.encoded).to include("3")
    expect(mail.body.encoded).to include("Missing")
  end

  it "does not match a maker from another organization" do
    create(:maker, name: "Outro", organization: create(:organization))
    csv = <<~CSV
      name,price,ibu,abv,maker,beer_style
      Solo,10,10,4,Outro,#{style.name}
    CSV
    import = enqueue(csv)

    expect { described_class.new.perform(import.id) }.not_to change(Beer, :count)
    expect(import.reload.row_log.first["errors"].join).to include("Outro")
  end

  it "marks the import failed when a later row raises and does not retry" do
    import = enqueue(beer_csv(style.name))
    allow_any_instance_of(Catalog::CsvImport::Creator).to receive(:create).and_wrap_original do |method, row|
      raise "disk full" if row["line"] == 3

      method.call(row)
    end

    described_class.new.perform(import.id)

    expect(import.reload.status).to eq("failed")
    expect(import.error_message).to include("disk full")
    expect(Beer.where(organization:).count).to eq(1)
    expect(described_class.sidekiq_options["retry"]).to eq(0)
  end
end
