module WinesHelper
  def build_params(hsh = {})
    @url_params.merge(hsh)
  end
end
