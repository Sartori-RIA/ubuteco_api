# frozen_string_literal: true

class Wine < Product
  searchkick callbacks: :async

  after_commit :enqueue_reindex_job

  validates :abv,
            :quantity_stock,
            :description,
            :vintage_wine,
            :visual,
            :ripening,
            :grapes,
            presence: true

  belongs_to :maker
  belongs_to :wine_style
  belongs_to :organization


  private

  def enqueue_reindex_job
    ReindexJob.perform_async(self.class.name)
  end
end
