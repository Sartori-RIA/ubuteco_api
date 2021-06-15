module FileSpecHelper
  class << self

    def image
      File.open(Dir[path_to('images')].sample)
    end

    private

    def path_to(folder)
      Rails.root.join('spec', 'samples', folder, '*')
    end
  end
end